import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/config/colors.dart';
import 'package:hyper_local/l10n/app_localizations.dart';
import 'package:hyper_local/screens/feed_page/bloc/available_orders_bloc/available_orders_bloc.dart';
import 'package:hyper_local/screens/feed_page/bloc/available_orders_bloc/available_orders_event.dart';
import 'package:hyper_local/screens/feed_page/bloc/deliveryboy_status_update_bloc/deliveryboy_status_bloc.dart';
import 'package:hyper_local/screens/feed_page/bloc/deliveryboy_status_update_bloc/deliveryboy_status_event.dart';
import 'package:hyper_local/screens/feed_page/bloc/my_orders_bloc/my_orders_bloc.dart';
import 'package:hyper_local/screens/feed_page/bloc/my_orders_bloc/my_orders_event.dart';
import 'package:hyper_local/screens/feed_page/bloc/my_orders_bloc/my_orders_state.dart';
import 'package:hyper_local/utils/widgets/custom_card.dart';
import 'package:hyper_local/utils/widgets/custom_text.dart';
import 'package:hyper_local/utils/widgets/loading_widget.dart';
import 'package:lottie/lottie.dart';

class OngoingOrders extends StatefulWidget {
  final bool isDeliveryBoyActive;
  const OngoingOrders({super.key, required this.isDeliveryBoyActive});

  @override
  State<OngoingOrders> createState() => _OngoingOrdersState();
}

class _OngoingOrdersState extends State<OngoingOrders> {
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
    // if (!widget.isDeliveryBoyActive) {
    //   return _buildInactiveWidget();
    // }
    final List<Map<String, dynamic>> pickups = [
      {
        "id": 1883,
        "status": "In Transit",
        "location": "Bhuj",
        "items": 1,
        "distance": 0.0,
        "collectAmount": 150,
      },
      {
        "id": 1882,
        "status": "In Transit",
        "location": "Mumbai",
        "items": 2,
        "distance": 2.5,
        "collectAmount": 220,
      },
    ];

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
        if (state is MyParcelsLoading) {
          return const Center(child: LoadingWidget());
        }

        if (state is MyOngoingParcelsLoaded) {
          final allOrders =
              state is MyOngoingParcelsLoaded ? (state).availableParcels : [];

          if (allOrders.isEmpty) {
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
          }
        }

        return ListView.builder(
          itemCount: pickups.length,
          itemBuilder: (context, index) {
            final item = pickups[index];

            return GestureDetector(
              onTap: () {
                context.pushNamed('orderDetails', extra: {'id': 1});
              },
              child: CustomCard(
                padding: EdgeInsets.all(16.w),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Top Row (Order ID + Status)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "#${item['id']}",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primaryColor),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            "In Transit", // you can map status dynamically
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    /// Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          item['location'],
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    /// Items + Distance
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 5.w),
                        Text("${item['items']} items"),
                        SizedBox(width: 15.w),
                        Icon(
                          Icons.directions_car_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 5.w),
                        Text("0.0 km"), // you can make dynamic later
                      ],
                    ),

                    SizedBox(height: 12.h),

                    /// Bottom Row (Collect + Map Button)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Collect Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Collect",
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "FCFA ${item['collectAmount']}",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor, // match UI
                              ),
                            ),
                          ],
                        ),

                        /// Map Button
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 18),
                              SizedBox(width: 5.w),
                              Text("Map"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
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
