import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/config/colors.dart';
import 'package:hyper_local/l10n/app_localizations.dart';

import 'package:hyper_local/screens/feed_page/bloc/deliveryboy_status_update_bloc/deliveryboy_status_bloc.dart';
import 'package:hyper_local/screens/feed_page/bloc/deliveryboy_status_update_bloc/deliveryboy_status_event.dart';
import 'package:hyper_local/screens/feed_page/bloc/my_orders_bloc/my_orders_bloc.dart';
import 'package:hyper_local/screens/feed_page/bloc/my_orders_bloc/my_orders_event.dart';
import 'package:hyper_local/screens/feed_page/bloc/my_orders_bloc/my_orders_state.dart';
import 'package:hyper_local/utils/widgets/custom_card.dart';
import 'package:hyper_local/utils/widgets/custom_text.dart';
import 'package:hyper_local/utils/widgets/loading_widget.dart';
import 'package:lottie/lottie.dart';

class OngoingParcels extends StatefulWidget {
  final bool isDeliveryBoyActive;
  const OngoingParcels({super.key, required this.isDeliveryBoyActive});

  @override
  State<OngoingParcels> createState() => _OngoingParcelsState();
}

class _OngoingParcelsState extends State<OngoingParcels> {
  bool _isRefreshing = false;
  @override
  void initState() {
    super.initState();

    if (widget.isDeliveryBoyActive) {
      context.read<MyOrdersBloc>().add(AvailableParcelsList());
    }
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

    return BlocConsumer<MyOrdersBloc, MyOrdersState>(
      listener: (context, state) {
        if (state is MyParcelsLoading) {
          setState(() {
            _isRefreshing = true;
          });
        } else if (state is MyOngoingParcelsLoaded || state is MyOrdersError) {
          setState(() {
            _isRefreshing = false;
          });
        }
      },
      builder: (context, state) {
        /// 🔄 Loading
        if (state is MyParcelsLoading) {
          return const Center(child: LoadingWidget());
        }

        if (state is MyOngoingParcelsLoaded) {
          final parcels = state.availableParcels;

          if (parcels.isEmpty) {
            return Column(
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
            );
          }

          return ListView.builder(
            // padding: EdgeInsets.all(16.w),
            itemCount: parcels.length,
            itemBuilder: (context, index) {
              final item = parcels[index];

              print("🧾 UI ITEM: ${item.pbNumber}");

              return CustomCard(
                onTap: () {
                  context.pushNamed(
                    'parcel-history-detail',
                    extra: {'id': item.pbId},
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
                          "#${item.pbNumber ?? item.pbId}",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Container(
                        //   padding: EdgeInsets.symmetric(
                        //     horizontal: 12.w,
                        //     vertical: 6.h,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     border: Border.all(color: AppColors.primaryColor),
                        //     borderRadius: BorderRadius.circular(20.r),
                        //   ),
                        //   child: Text(
                        //     item.status ?? "N/A",
                        //     style: TextStyle(
                        //       color: AppColors.primaryColor,
                        //       fontWeight: FontWeight.w600,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    /// Location
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 18),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Text(
                            item.receiverAddress ?? "No Address",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    /// Receiver
                    Text(
                      "Receiver: ${item.receiverName ?? '-'}",
                      style: TextStyle(color: Colors.grey),
                    ),

                    SizedBox(height: 12.h),

                    /// Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "FCFA ${item.deliveryCharge ?? '0'}",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),

                        Text(
                          item.status ?? "N/A",
                          style: TextStyle(
                            color: AppColors.accentOrange,
                            fontWeight: FontWeight.w600,
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

        /// ⚠️ Fallback (IMPORTANT → prevents curly error)
        return const Center(child: Text("No Data"));
      },
    );
  }

  Widget _buildInactiveWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
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
