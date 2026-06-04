import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/l10n/app_localizations.dart';
import 'package:hyper_local/screens/feed_page/bloc/deliveryboy_status_update_bloc/deliveryboy_status_bloc.dart';
import 'package:hyper_local/screens/feed_page/bloc/deliveryboy_status_update_bloc/deliveryboy_status_event.dart';

import 'package:hyper_local/screens/feed_page/bloc/my_orders_bloc/my_orders_bloc.dart';
import 'package:hyper_local/screens/feed_page/bloc/my_orders_bloc/my_orders_event.dart';
import 'package:hyper_local/screens/feed_page/bloc/my_orders_bloc/my_orders_state.dart';
import 'package:hyper_local/screens/feed_page/widgets/parcel_history/parcel_history_detail.dart';

import 'package:hyper_local/utils/widgets/custom_card.dart';
import 'package:hyper_local/utils/widgets/custom_text.dart';
import 'package:hyper_local/utils/widgets/loading_widget.dart';
import 'package:lottie/lottie.dart';

class ParcelHistory extends StatefulWidget {
  final bool isDeliveryBoyActive;
  const ParcelHistory({super.key, required this.isDeliveryBoyActive});

  @override
  State<ParcelHistory> createState() => _ParcelHistoryState();
}

class _ParcelHistoryState extends State<ParcelHistory> {
  @override
  void initState() {
    super.initState();

    context.read<MyOrdersBloc>().add(HistoryParcelsList());
  }

  @override
  Widget build(BuildContext context) {
    final statusState = context.watch<DeliveryBoyStatusBloc>().state;

    final isOnline = statusState.isOnline;
    if (!isOnline) {
      return _buildInactiveWidget();
    }
    // if (!widget.isDeliveryBoyActive) {
    //   return _buildInactiveWidget();
    // }
    return RefreshIndicator(
      onRefresh: () async {
        try {
          context.read<MyOrdersBloc>().add(HistoryParcelsList());
          context.read<DeliveryBoyStatusBloc>().add(const CheckApiStatus());
        } catch (e) {
          //
        }
      },
      child: BlocBuilder<MyOrdersBloc, MyOrdersState>(
        builder: (context, state) {
          /// 🔄 Loading
          if (state is MyHistoryParcelsLoading) {
            return const Center(child: LoadingWidget());
          }

          /// ❌ Error
          if (state is MyOrdersError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 100.h),
                const Center(child: Text("Failed to load parcels")),
              ],
            );
          }

          /// ✅ Success
          if (state is MyHistoryParcelsLoaded) {
            final parcels = state.historyParcels;

            print("📦 HISTORY COUNT: ${parcels.length}");

            if (parcels.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 100.h),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/png/no-record-found.png',
                          width: 100.w,
                          height: 100.h,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          AppLocalizations.of(context)?.noRecordFound ??
                              "No Record Found",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              // padding: EdgeInsets.all(16.w),
              itemCount: parcels.length,
              itemBuilder: (context, index) {
                final parcel = parcels[index];

                print("🧾 HISTORY ITEM: ${parcel.pbNumber}");

                return CustomCard(
                  onTap: () {
                    context.pushNamed(
                      'parcel-history-detail',
                      extra: {'id': parcel.pbId},
                    );
                  },
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Top Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "#${parcel.pbNumber ?? parcel.pbId}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //     horizontal: 10,
                          //     vertical: 4,
                          //   ),
                          //   decoration: BoxDecoration(
                          //     color: Colors.green.withOpacity(0.15),
                          //     borderRadius: BorderRadius.circular(20),
                          //   ),
                          //   child: Text(
                          //     parcel.status ?? "Completed",
                          //     style: const TextStyle(
                          //       color: Colors.green,
                          //       fontWeight: FontWeight.w500,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              parcel.receiverAddress ?? "No Address",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// Receiver
                      Text(
                        "Receiver: ${parcel.receiverName ?? '-'}",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),

                      const SizedBox(height: 12),

                      /// Amount
                      const Text(
                        "Delivery Charge",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "FCFA ${parcel.deliveryCharge ?? '0'}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            parcel.status ?? "Completed",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }

          /// ⚠️ Fallback
          return const Center(child: Text("No Data"));
        },
      ),
    );
  }

  Widget _buildInactiveWidget() {
    return RefreshIndicator(
      onRefresh: () async {
        try {
          context.read<DeliveryBoyStatusBloc>().add(const CheckApiStatus());
        } catch (e) {
          //
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: 0.7.sh,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/notactive.json',
                width: 200.w,
                height: 200.h,
                fit: BoxFit.cover,
                repeat: true,
                animate: true,
              ),
              // SizedBox(height: 14.h),
              CustomText(
                text: AppLocalizations.of(context)!.accountInactive,
                fontSize: 22.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 12.h),
              CustomText(
                text: AppLocalizations.of(context)!.activateAccountToViewOrders,
                fontSize: 16.sp,
                color: Colors.grey[600],
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: () {
                  // Try to activate the status
                  context.read<DeliveryBoyStatusBloc>().add(ToggleStatus(true));
                },
                icon: Icon(
                  Icons.power_settings_new,
                  color: Colors.white,
                  size: 20.sp,
                ),
                label: CustomText(
                  text: AppLocalizations.of(context)!.activateAccount,
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                ),
              ),
              SizedBox(height: 16.h),
              CustomText(
                text: AppLocalizations.of(context)!.tapPowerButtonToGoOnline,
                fontSize: 14.sp,
                color: Colors.grey[500],
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
