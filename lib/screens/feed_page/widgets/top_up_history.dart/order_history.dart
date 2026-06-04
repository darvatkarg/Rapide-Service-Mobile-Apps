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
import 'package:hyper_local/utils/currency_formatter.dart';
import 'package:hyper_local/utils/widgets/custom_card.dart';
import 'package:hyper_local/utils/widgets/custom_text.dart';
import 'package:hyper_local/utils/widgets/loading_widget.dart';
import 'package:lottie/lottie.dart';

class OrderHistory extends StatefulWidget {
  final bool isDeliveryBoyActive;
  const OrderHistory({super.key, required this.isDeliveryBoyActive});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  @override
  void initState() {
    super.initState();

    context.read<MyOrdersBloc>().add(AllMyOrdersList(type: "all"));
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;
      case "assigned":
        return Colors.blue;
      case "completed":
        return Colors.green;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
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

    return RefreshIndicator(
      onRefresh: () async {
        try {
          context.read<MyOrdersBloc>().add(
            AllMyOrdersList(type: "all", forceRefresh: true),
          );
          context.read<DeliveryBoyStatusBloc>().add(const CheckApiStatus());
        } catch (e) {
          //
        }
      },
      child: BlocBuilder<MyOrdersBloc, MyOrdersState>(
        builder: (context, state) {
          if (state is MyOrdersLoading) {
            return const Center(child: LoadingWidget());
          }

          if (state is MyOrdersError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 100.h),
                const Center(child: Text("Failed to load orders")),
              ],
            );
          }

          if (state is MyOrdersLoaded) {
            final orders = state.myOrders;
            print("📦 HISTORY COUNT: ${orders}");

            if (orders.isEmpty) {
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
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return CustomCard(
                  onTap: () {
                    context.pushNamed(
                      'order-history-detail',
                      extra: {'id': order.id},
                    );
                  },
                  padding: EdgeInsets.all(16.w),
                  // margin: EdgeInsets.only(bottom: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔹 TOP ROW (UUID + STATUS)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "#${order.uuid ?? order.id}",
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
                          //     border: Border.all(
                          //       color: getStatusColor(order.status ?? ""),
                          //     ),
                          //     borderRadius: BorderRadius.circular(20.r),
                          //   ),
                          //   child: Text(
                          //     order.status ?? "N/A",
                          //     style: TextStyle(
                          //       color: getStatusColor(order.status ?? ""),
                          //       fontWeight: FontWeight.w600,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),

                      SizedBox(height: 10.h),

                      /// 🔹 PAYMENT METHOD
                      Row(
                        children: [
                          Icon(Icons.payment_outlined, size: 18),
                          SizedBox(width: 6.w),
                          Text(
                            order.paymentMethod ?? "Unknown",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      /// 🔹 DATE
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 18),
                          SizedBox(width: 6.w),
                          Text(
                            order.createdAt ?? "-",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      /// 🔹 AMOUNT
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "FCFA ${order.finalTotal ?? '0'}",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          Text(
                            order.status ?? "N/A",
                            style: TextStyle(
                              color: getStatusColor(order.status ?? ""),
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

          return const Center(child: LoadingWidget());
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
