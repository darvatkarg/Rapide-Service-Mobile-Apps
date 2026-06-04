import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/config/theme.dart';
import 'package:hyper_local/router/app_routes.dart';
import 'package:hyper_local/screens/my_orders/bloc/get_my_order/get_my_order_bloc.dart';
import 'package:hyper_local/screens/my_orders/bloc/get_my_order/get_my_order_event.dart';
import 'package:hyper_local/screens/my_orders/bloc/get_my_order/get_my_order_state.dart';
import 'package:hyper_local/screens/my_orders/model/ongoing_parcel_list_model.dart';
import 'package:hyper_local/screens/my_orders/view/order_detail_page.dart';
import 'package:hyper_local/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:hyper_local/utils/widgets/custom_refresh_indicator.dart';
import 'package:hyper_local/utils/widgets/custom_scaffold.dart';
import 'package:hyper_local/utils/widgets/empty_states_page.dart';
import 'package:intl/intl.dart';
import '../../../config/helper.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/my_order_card.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  int selectedTab = 0;
  @override
  void initState() {
    super.initState();
    // context.read<GetMyOrderBloc>().add(FetchMyOrder());
    context.read<GetMyOrderBloc>().add(FetchMyOngoingOrders());
    print("MyOrdersPage opened");
  }

  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isLoaded) {
      _isLoaded = true;
      context.read<GetMyOrderBloc>().add(FetchMyOngoingOrders());
      print("MyOrdersPage API triggered");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CustomScaffold(
      showViewCart: false,
      title: l10n?.myOrders,
      showAppBar: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: BlocBuilder<GetMyOrderBloc, GetMyOrderState>(
        builder: (context, state) {
          if (state is GetMyOrderLoading) {
            return const Center(
              child: CustomCircularProgressIndicator(),
            );
          } else if (state is GetMyOngoingOrdersLoaded ||
              state is GetMyParcelsHistoryLoaded) {
            final orders = state is GetMyOngoingOrdersLoaded
                ? state.parcelBookingData
                : (state as GetMyParcelsHistoryLoaded).parcelBookingData;
            // if (state.myOrderData.isEmpty) {
            //   return Center(
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Icon(
            //           Icons.shopping_bag_outlined,
            //           size: 80,
            //           color: Colors.grey[400],
            //         ),
            //         const SizedBox(height: 16),
            //         Text(
            //           l10n?.noOrdersYet ?? 'No orders yet',
            //           style: TextStyle(
            //             fontSize: 18,
            //             color: Colors.grey[600],
            //             fontWeight: FontWeight.w500,
            //           ),
            //         ),
            //       ],
            //     ),
            //   );
            // }
            return CustomRefreshIndicator(
                onRefresh: () async {
                  if (selectedTab == 0) {
                    context.read<GetMyOrderBloc>().add(FetchMyOngoingOrders());
                  } else {
                    context.read<GetMyOrderBloc>().add(FetchMyParcelsHistory());
                  }
                },
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          tabButton(l10n?.runningOrders ?? "Running Orders", 0),
                          SizedBox(
                            width: 10,
                          ),
                          tabButton(l10n?.historyOrders ?? "History Orders", 1),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: orders.isEmpty
                          ? Center(
                              child:
                                  Text(l10n?.noOrdersYet ?? "No orders found"))
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final order = orders[index];

                                return OrderCard(
                                  order: order,
                                  onTap: () {
                                    context.pushNamed(
                                      'parcel-order-detail',
                                      extra: {
                                        'id': order.pbId,
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                    )
                  ],
                ));
          } else if (state is GetMyOrderFailed) {
            return NoOrderPage(
              onRetry: () {
                context.read<GetMyOrderBloc>().add(FetchMyOngoingOrders());
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget tabButton(String title, int index) {
    bool isSelected = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });

        if (index == 0) {
          context.read<GetMyOrderBloc>().add(FetchMyOngoingOrders());
        } else {
          context.read<GetMyOrderBloc>().add(FetchMyParcelsHistory());
        }
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
          )
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final ParcelBookingData order;
  final VoidCallback? onTap;

  OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });
  final List<String> categgoryType = [
    'assets/images/gift.png',
    'assets/images/document.png',
    'assets/images/electronics.png',
    'assets/images/packages.png',
  ];

  String getCategoryImage() {
    final type = order.pbType?.toLowerCase() ?? '';
    if (type == "gift") {
      return categgoryType[0];
    } else if (type == "document") {
      return categgoryType[1];
    } else if (type == "electronics" || type == "electronic") {
      return categgoryType[2];
    } else {
      return categgoryType[3];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Parcel Icon
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                getCategoryImage(),
                width: 60.w,
                height: 60.h,
              ),
            ),

            const SizedBox(width: 12),

            /// Order Info (takes remaining space)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "#${order.pbNumber}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// Parcel Type & Category
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          AppHelpers.translateDeliveryType(
                              context, order.deliveryType),
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          AppHelpers.translateParcelType(context, order.pbType),
                          style: const TextStyle(
                            color: AppTheme.accentOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

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
                          order.rcAddress ??
                              (l10n?.noAddressFound ?? "No Address"),
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${l10n?.sender ?? "Sender"} : ${order.sdName}",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${l10n?.receiver ?? "Receiver"} : ${order.rcName}",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat("dd MMM yyyy, hh:mm a")
                        .format(DateTime.parse(order.createdAt ?? "")),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),

                  Text(
                    AppHelpers.translateParcelStatus(context, order.pbStatus),
                    style: TextStyle(
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (order.pbStatus?.toLowerCase() == 'out for delivery')
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          GoRouter.of(context).push(
                            AppRoutes.deliveryTracking,
                            extra: {
                              'order-slug': order.pbId.toString(),
                              'isParcel': true,
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.delivery_dining,
                          size: 18,
                          color: AppTheme.primaryColor,
                        ),
                        label: Text(
                          l10n?.trackYourDelivery ?? "Track Delivery",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    )
                ],
              ),
            ),

            const SizedBox(width: 8),

            /// Status Column
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.end,
            //   children: [
            //     Container(
            //       padding:
            //           const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            //       decoration: BoxDecoration(
            //         color: AppTheme.primaryColor.withValues(alpha: 0.1),
            //         borderRadius: BorderRadius.circular(20),
            //       ),
            //       child: Text(
            //         order.pbStatus ?? "",
            //         style: const TextStyle(
            //           color: AppTheme.primaryColor,
            //           fontWeight: FontWeight.w600,
            //           fontSize: 12,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
