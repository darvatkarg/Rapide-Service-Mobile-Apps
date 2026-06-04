import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/config/colors.dart';
import 'package:hyper_local/l10n/app_localizations.dart';
import 'package:hyper_local/router/app_routes.dart';
import 'package:hyper_local/screens/feed_page/bloc/available_orders_bloc/available_orders_bloc.dart';
import 'package:hyper_local/screens/feed_page/bloc/available_orders_bloc/available_orders_event.dart';
import 'package:hyper_local/screens/feed_page/bloc/my_orders_bloc/my_orders_bloc.dart';
import 'package:hyper_local/screens/feed_page/bloc/my_orders_bloc/my_orders_event.dart';
import 'package:hyper_local/screens/feed_page/bloc/order_details_bloc/order_details_bloc.dart';
import 'package:hyper_local/screens/feed_page/bloc/order_details_bloc/order_details_event.dart';
import 'package:hyper_local/screens/feed_page/bloc/order_details_bloc/order_details_state.dart';
import 'package:hyper_local/screens/inactive_delievryboy/bloc/inactive_page_stats/home_stats_bloc.dart';
import 'package:hyper_local/screens/inactive_delievryboy/bloc/inactive_page_stats/home_stats_event.dart';
import 'package:hyper_local/utils/widgets/custom_appbar_without_navbar.dart';
import 'package:hyper_local/utils/widgets/custom_scaffold.dart';
import 'package:hyper_local/utils/widgets/loading_widget.dart';
import 'package:intl/intl.dart';

class OrderHistoryDetail extends StatefulWidget {
  final String id;

  const OrderHistoryDetail({super.key, required this.id});

  @override
  State<OrderHistoryDetail> createState() => _OrderHistoryDetailState();
}

class _OrderHistoryDetailState extends State<OrderHistoryDetail> {
  @override
  void initState() {
    super.initState();

    context.read<OrderDetailsBloc>().add(
      FetchOrderDetails(int.parse(widget.id)),
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;
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
    return BlocListener<OrderDetailsBloc, OrderDetailsState>(
      listener: (context, state) {
        if (state is OrderStatusUpdated) {
          context.read<HomeStatsBloc>().add(RefreshHomeStats());
          context.read<AvailableOrdersBloc>().add(
            AllAvailableOrdersList(forceRefresh: true),
          );

          context.read<MyOrdersBloc>().add(AllMyOrdersList(type: "all"));
          Future.delayed(const Duration(milliseconds: 200), () {
            if (context.mounted) {
              context.go(AppRoutes.home);
            }
          });
        }

        if (state is OrderDetailsError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Something went wrong")));
        }
      },
      child: CustomScaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBarWithoutNavbar(
          title: "Order Details",
          showRefreshButton: false,
          showThemeToggle: false,
        ),

        bottomNavigationBar: BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
          buildWhen: (previous, current) {
            if (current is OrderStatusUpdated) return false;
            return true;
          },
          builder: (context, state) {
            if (state is! OrderDetailsSuccess) return SizedBox.shrink();

            final order = state.order;
            final status =
                order.status?.toLowerCase().replaceAll('_', ' ').trim();
            final deliveryType = order.deliveryType?.toLowerCase().trim();
            print('order status$status');

            print(" ORDER STATUS: ${order.status}");
            if (status != "assigned" &&
                status != "out for delivery" &&
                status != "in transit") {
              return SizedBox.shrink();
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                  child:
                      status == "assigned"
                          ? SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                              ),
                              onPressed: () {
                                final nextStatus =
                                    deliveryType == "standard"
                                        ? "Out For Delivery"
                                        : "In Transit";

                                context.read<OrderDetailsBloc>().add(
                                  ChangeOrderStatus(
                                    id: order.id.toString(),
                                    status: nextStatus,
                                  ),
                                );
                              },
                              child: Text(
                                deliveryType == "standard"
                                    ? "Out for Delivery"
                                    : "In Transit",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.primaryColor,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14.h,
                                    ),
                                  ),
                                  onPressed: () {
                                    context.read<OrderDetailsBloc>().add(
                                      ChangeOrderStatus(
                                        id: order.id.toString(),
                                        status: "Completed",
                                      ),
                                    );
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)?.cancel ??
                                        "Cancel",
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.successColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14.h,
                                    ),
                                  ),
                                  onPressed: () {
                                    context.read<OrderDetailsBloc>().add(
                                      ChangeOrderStatus(
                                        id: order.id.toString(),
                                        status: "Completed",
                                      ),
                                    );
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)?.completed ??
                                        "Completed",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            );
          },
        ),

        body: BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
          buildWhen: (previous, current) {
            if (current is OrderStatusUpdated) return false;
            return true;
          },
          builder: (context, state) {
            if (state is OrderDetailsLoading) {
              return const Center(child: LoadingWidget());
            }

            if (state is OrderDetailsSuccess) {
              final order = state.order;

              final status =
                  order.status?.toLowerCase().replaceAll('_', ' ').trim();

              return SingleChildScrollView(
                padding: EdgeInsets.all(12.h),
                child: Column(
                  children: [
                    sectionCard(
                      title:
                          AppLocalizations.of(context)?.generalInfo ??
                          "General Info",
                      children: [
                        SizedBox(height: 10.h),
                        infoRow("Order ID", order.uuid ?? "-"),
                        const Divider(),
                        infoRow(
                          AppLocalizations.of(context)?.orderDate ??
                              "Order Date",
                          DateFormat(
                            'dd MMM yyyy, hh:mm a',
                          ).format(DateTime.parse(order.createdAt.toString())),
                        ),
                        const Divider(),
                        infoRow(
                          "Status",
                          order.status ?? "-",
                          valueColor: AppColors.primaryColor,
                          // valueColor: getStatusColor(order.status ?? ""),
                        ),
                        const Divider(),
                        infoRow("Payment Method", order.paymentMethod ?? "-"),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    sectionCard(
                      title:
                          AppLocalizations.of(context)?.receiverDetails ??
                          "Receiver Details",
                      trailing:
                          (status == "assigned" ||
                                  status == "out for delivery" ||
                                  status == "in transit")
                              ? GestureDetector(
                                onTap: () {
                                  print(
                                    " Receiver Location: Lat=${order.shippingLatitude}, Long=${order.shippingLongitude}",
                                  );

                                  GoRouter.of(context).pushNamed(
                                    'delivery-zone-map',
                                    extra: {
                                      'rc_lat':
                                          order.shippingLatitude.toString(),
                                      'rc_long':
                                          order.shippingLongitude.toString(),
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    color: AppColors.primaryColor,
                                    size: 20,
                                  ),
                                ),
                              )
                              : null,

                      // trailing: GestureDetector(
                      //   onTap: () {
                      //     print(
                      //       " Receiver Location: Lat=${order.shippingLatitude}, Long=${order.shippingLatitude}",
                      //     );
                      //     GoRouter.of(context).pushNamed(
                      //       'delivery-zone-map',
                      //       extra: {
                      //         'rc_lat': order.shippingLatitude.toString(),
                      //         'rc_long': order.shippingLatitude.toString(),
                      //       },
                      //     );
                      //   },
                      //   child: Container(
                      //     padding: const EdgeInsets.all(8),
                      //     decoration: BoxDecoration(
                      //       color: AppColors.primaryColor.withOpacity(0.1),
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     child: Icon(
                      //       Icons.location_on,
                      //       color: AppColors.primaryColor,
                      //       size: 20,
                      //     ),
                      //   ),
                      // ),
                      children: [
                        SizedBox(height: 10.h),
                        detailRow(Icons.person, order.shippingName ?? "N/A"),
                        detailRow(Icons.phone, order.shippingPhone ?? "N/A"),
                        detailRow(
                          Icons.location_on,
                          order.shippingAddress1 ?? "N/A",
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    /// 🔹 ITEMS LIST
                    sectionCard(
                      title: "Items",
                      children: [
                        ...order.items!.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Image.network(
                                  item.product?.image ?? "",
                                  width: 50,
                                  height: 50,
                                  errorBuilder:
                                      (_, __, ___) => Icon(Icons.image),
                                ),
                                SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title ?? "-",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Qty: ${item.quantity}",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),

                                Text("FCFA ${item.price}"),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    /// 🔹 STORE INFO
                    sectionCard(
                      title: "Store Details",
                      children: [
                        ...order.items!.map((item) {
                          return detailRow(
                            Icons.store,
                            item.store?.name ?? "-",
                          );
                        }).toList(),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    /// 🔹 PAYMENT DETAILS
                    // sectionCard(
                    //   title: "Payment Details",
                    //   children: [
                    //     SizedBox(height: 10.h),

                    //     billingRow("Subtotal", "FCFA ${order.subtotal ?? "0"}"),
                    //     SizedBox(height: 6),

                    //     billingRow(
                    //       "Final Total",
                    //       "FCFA ${order.finalTotal ?? "0"}",
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(height: 10.h),
                    Container(
                      // margin: const EdgeInsets.symmetric(
                      //     horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// PAYMENT DETAILS HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)?.paymentDetails ??
                                    "Payment Details",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  order.paymentStatus == "pending"
                                      ? "Unpaid"
                                      : "Paid",
                                  style: TextStyle(
                                    color:
                                        order.paymentStatus == "pending"
                                            ? AppColors.primaryColor
                                            : Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10.h),

                          /// PAYMENT METHOD
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.payments_outlined, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    AppLocalizations.of(
                                          context,
                                        )?.paymentMethod ??
                                        "Payment Method",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              Text(
                                order.paymentMethod.toString(),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10.h),

                          /// BILLING SUMMARY TITLE
                          Text(
                            AppLocalizations.of(context)?.billingSummary ??
                                "Billing Summary",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          SizedBox(height: 10.h),

                          /// DELIVERY FEE
                          billingRow(
                            AppLocalizations.of(context)?.deliveryFee ??
                                "Delivery Fee",
                            "(+) FCFA ${order.subtotal ?? "0"}",
                          ),

                          SizedBox(height: 10.h),

                          const Divider(),

                          const SizedBox(height: 10),

                          /// TOTAL AMOUNT
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)?.totalAmount ??
                                        "Total Amount",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withOpacity(
                                        .15,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)?.due ??
                                          "Due",
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text("FCFA ${order.finalTotal ?? "0"}"),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 80.h),
                  ],
                ),
              );
            }

            return Center(child: Text("No Data"));
          },
        ),
      ),
    );
  }

  Widget sectionCard({
    required String title,
    required List<Widget> children,
    Widget? trailing, // 👈 NEW
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 HEADER WITH TRAILING
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              if (trailing != null) trailing,
            ],
          ),

          ...children,
        ],
      ),
    );
  }

  Widget infoRow(
    String label,
    String value, {
    Color valueColor = Colors.black,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: valueColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget rateWidget() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return Text(
                    'How was your shopping experience?',
                    style: TextStyle(fontSize: 12.sp),
                  );
                },
              ),
            ),
            SizedBox(width: 5.w),
          ],
        ),
      ),
    );
  }
}

Widget billingRow(String title, String amount) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(color: Colors.black87, fontSize: 16)),
      Text(amount, style: const TextStyle(fontSize: 16)),
    ],
  );
}

class detailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const detailRow(this.icon, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
