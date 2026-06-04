import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/config/colors.dart';
import 'package:hyper_local/utils/widgets/custom_card.dart';
import 'package:lottie/lottie.dart';
import '../../../../utils/widgets/custom_text.dart';
import '../../../../utils/widgets/loading_widget.dart';
import '../../bloc/available_orders_bloc/available_orders_bloc.dart';
import '../../bloc/available_orders_bloc/available_orders_event.dart';
import '../../bloc/available_orders_bloc/available_orders_state.dart';
import 'available_order_card.dart';
import 'package:hyper_local/l10n/app_localizations.dart';
import '../../bloc/deliveryboy_status_update_bloc/deliveryboy_status_bloc.dart';
import '../../bloc/deliveryboy_status_update_bloc/deliveryboy_status_event.dart';
import 'package:hyper_local/screens/inactive_delievryboy/bloc/inactive_page_stats/home_stats_bloc.dart';
import 'package:hyper_local/screens/inactive_delievryboy/bloc/inactive_page_stats/home_stats_event.dart';
import '../../bloc/my_orders_bloc/my_orders_bloc.dart';
import '../../bloc/my_orders_bloc/my_orders_event.dart';

class AvailableOrdersSection extends StatefulWidget {
  final bool isDeliveryBoyActive; // Add this parameter

  const AvailableOrdersSection({
    super.key,
    required this.isDeliveryBoyActive, // Add this parameter
  });

  @override
  State<AvailableOrdersSection> createState() => _AvailableOrdersSectionState();
}

class _AvailableOrdersSectionState extends State<AvailableOrdersSection> {
  bool _isRefreshing = false; // Add loading state for refresh button

  @override
  void initState() {
    super.initState();
    // Only load available orders when the delivery boy is active
    if (widget.isDeliveryBoyActive) {
      context.read<AvailableOrdersBloc>().add(AllAvailableOrdersList());
    }
  }

  @override
  void didUpdateWidget(covariant AvailableOrdersSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isDeliveryBoyActive && !oldWidget.isDeliveryBoyActive) {
      context.read<AvailableOrdersBloc>().add(
        AllAvailableOrdersList(forceRefresh: true),
      );
    }
  }

  void _onScroll(ScrollNotification scrollNotification) {
    if (scrollNotification.metrics.pixels >=
        scrollNotification.metrics.maxScrollExtent - 200) {
      context.read<AvailableOrdersBloc>().add(LoadMoreAvailableOrders(''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusState = context.watch<DeliveryBoyStatusBloc>().state;

    final isOnline = statusState.isOnline;
    if (!isOnline) {
      return _buildInactiveWidget();
    }
    // If delivery boy is inactive, show inactive widget
    // if (!widget.isDeliveryBoyActive) {
    //   return _buildInactiveWidget();
    // }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeStatsBloc>().add(RefreshHomeStats());
        context.read<AvailableOrdersBloc>().add(
          AllAvailableOrdersList(forceRefresh: true),
        );
        context.read<MyOrdersBloc>().add(AvailableParcelsList());
        // Wait a moment for the BLoC to process
        await Future.delayed(const Duration(milliseconds: 800));
      },
      child: BlocConsumer<AvailableOrdersBloc, AvailableOrdersState>(
        listener: (context, state) {
          // if (state is AvailableOrdersError) {
          //   ToastManager.show(
          //     context: context,
          //     message: state.errorMessage,
          //     type: ToastType.error,
          //   );
          // }
          // Update loading state based on bloc state
          if (state is AvailableOrdersLoading) {
            setState(() {
              _isRefreshing = true;
            });
          } else if (state is AvailableOrdersLoaded ||
              state is AvailableOrdersError) {
            setState(() {
              _isRefreshing = false;
            });
          }
        },
        builder: (context, state) {
          if (state is AvailableOrdersLoading) {
            return const Center(child: LoadingWidget());
          }

          if (state is AvailableOrdersLoaded ||
              state is AvailableOrdersRefreshing) {
            final allOrders =
                state is AvailableOrdersLoaded
                    ? (state).availableOrders
                    : (state as AvailableOrdersRefreshing).availableOrders;
            print('###########$allOrders');
            final totalOrders =
                state is AvailableOrdersLoaded
                    ? (state).totalOrders
                    : (state as AvailableOrdersRefreshing).totalOrders;
            final hasReachedMax =
                state is AvailableOrdersLoaded
                    ? (state).hasReachedMax
                    : (state as AvailableOrdersRefreshing).hasReachedMax;

            if (allOrders.isEmpty) {
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
            return NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                _onScroll(scrollNotification);
                return false;
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: allOrders.length,
                itemBuilder: (context, index) {
                  final order = allOrders[index];

                  return CustomCard(
                    onTap: () {
                      context.pushNamed(
                        'order-history-detail',
                        extra: {'id': order.id},
                      );
                      print('order id${order.id}');
                    },
                    padding: EdgeInsets.all(16.w),
                    // margin: EdgeInsets.only(bottom: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 🔹 TOP ROW (Order ID + Status)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "#${order.uuid ?? order.id.toString()}",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
              ),
            );

            /*
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Padding(
              //   padding: EdgeInsets.symmetric(vertical: 16.0.h),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       CustomText(
              //         text: AppLocalizations.of(context)!.availableOrders,
              //         fontSize: 20.sp,
              //         fontWeight: FontWeight.bold,
              //       ),
              //       CustomText(
              //         text: AppLocalizations.of(
              //           context,
              //         )!.ordersCount(totalOrders),
              //         fontSize: 14.sp,
              //         color: Theme.of(
              //           context,
              //         ).colorScheme.onSurface.withValues(alpha: 0.6),
              //       ),
              //     ],
              //   ),
              // ),
              // Expanded(
              //   child: Stack(
              //     children: [
              //       RefreshIndicator(
              //         onRefresh: () async {
              //           context.read<AvailableOrdersBloc>().add(
              //             AllAvailableOrdersList(forceRefresh: true),
              //           );
              //         },
              //         child: ListView.builder(
              //           controller: _scrollController,
              //           physics:
              //               const AlwaysScrollableScrollPhysics(), // Enable overscroll even with few items
              //           padding: EdgeInsets.only(bottom: 16.h),
              //           itemCount: allOrders.length + (hasReachedMax ? 0 : 1),
              //           itemBuilder: (context, index) {
              //             if (index >= allOrders.length) {
              //               return Padding(
              //                 padding: EdgeInsets.symmetric(horizontal: 16.w),
              //                 child: Center(child: LoadingWidget(size: 100.sp)),
              //               );
              //             }

              //             final order = allOrders[index];
              //             return AvailableOrderCard(order: order);
              //           },
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          );

          */
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200.h,
                  width: 250.w,
                  child: Lottie.asset(
                    'assets/lottie/NotDataFound.json',
                    width: 150.w,
                    height: 150.h,
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                  ),
                ),
                // Image.asset(AppImages.noOrder, height: 200.h, width: 200.w),
                SizedBox(height: 16.h),
                CustomText(
                  text: AppLocalizations.of(context)!.noAvailableOrders,
                  fontSize: 18.sp,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 8.h),
                CustomText(
                  text: AppLocalizations.of(context)!.ordersWillAppearHere,
                  fontSize: 14.sp,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed:
                      _isRefreshing
                          ? null
                          : () {
                            // Set loading state immediately when button is clicked
                            setState(() {
                              _isRefreshing = true;
                            });
                            context.read<AvailableOrdersBloc>().add(
                              AllAvailableOrdersList(forceRefresh: true),
                            );
                          },
                  icon:
                      _isRefreshing
                          ? SizedBox(
                            width: 20.sp,
                            height: 20.sp,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                  label: CustomText(
                    text:
                        _isRefreshing
                            ? AppLocalizations.of(context)!.refreshing
                            : AppLocalizations.of(context)!.refresh,
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInactiveWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
