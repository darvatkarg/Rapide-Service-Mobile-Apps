import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/config/colors.dart';
import 'package:hyper_local/l10n/app_localizations.dart';
import 'package:hyper_local/router/app_routes.dart';
import 'package:hyper_local/screens/feed_page/bloc/my_orders_bloc/my_orders_bloc.dart';
import 'package:hyper_local/screens/feed_page/bloc/my_orders_bloc/my_orders_event.dart';
import 'package:hyper_local/screens/feed_page/bloc/order_details_bloc/order_details_bloc.dart';
import 'package:hyper_local/screens/feed_page/bloc/order_details_bloc/order_details_event.dart';
import 'package:hyper_local/screens/feed_page/bloc/order_details_bloc/order_details_state.dart';
import 'package:hyper_local/screens/feed_page/bloc/available_orders_bloc/available_orders_bloc.dart';
import 'package:hyper_local/screens/feed_page/bloc/available_orders_bloc/available_orders_event.dart';
import 'package:hyper_local/screens/inactive_delievryboy/bloc/inactive_page_stats/home_stats_bloc.dart';
import 'package:hyper_local/screens/inactive_delievryboy/bloc/inactive_page_stats/home_stats_event.dart';
import 'package:hyper_local/utils/widgets/custom_appbar_without_navbar.dart';
import 'package:hyper_local/utils/widgets/custom_scaffold.dart';
import 'package:hyper_local/utils/widgets/loading_widget.dart';
import 'package:intl/intl.dart';

class ParcelHistoryDetail extends StatefulWidget {
  final String id;
  const ParcelHistoryDetail({super.key, required this.id});

  @override
  State<ParcelHistoryDetail> createState() => _ParcelHistoryDetailState();
}

class _ParcelHistoryDetailState extends State<ParcelHistoryDetail> {
  bool _navigated = false;
  @override
  void initState() {
    super.initState();
    apiCall();
  }

  Future<void> apiCall() async {
    context.read<OrderDetailsBloc>().add(
      FetchParcelDetails(widget.id.toString()),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
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

  final List<String> categgoryType = [
    'assets/images/gift.png',
    'assets/images/document.png',
    'assets/images/electronics.png',
    'assets/images/packages.png',
  ];

  String getCategoryImage(String? type) {
    if (type == "Gift") {
      return categgoryType[0];
    } else if (type == "Document") {
      return categgoryType[1];
    } else if (type == "Electronics") {
      return categgoryType[2];
    } else {
      return categgoryType[3];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderDetailsBloc, OrderDetailsState>(
      listener: (context, state) {
        if (state is ParcelStatusUpdated) {
          context.read<HomeStatsBloc>().add(RefreshHomeStats());
          context.read<MyOrdersBloc>().add(AvailableParcelsList());
          context.read<AvailableOrdersBloc>().add(
            AllAvailableOrdersList(forceRefresh: true),
          );
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
          title: AppLocalizations.of(context)!.parcelDetails,
          showRefreshButton: true,
          showThemeToggle: false,
          onRefreshPressed: () {},
        ),

        bottomNavigationBar: BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
          buildWhen: (previous, current) {
            if (current is ParcelStatusUpdated) return false;
            return true;
          },
          builder: (context, state) {
            if (state is! ParcelDetailsSuccess) return SizedBox.shrink();

            final parcel = state.order;
            final status = parcel.pbStatus?.toLowerCase();

            print("📦 PARCEL STATUS: ${parcel.pbStatus}");
            if (status != "assigned" && status != "out for delivery") {
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
                                context.read<OrderDetailsBloc>().add(
                                  ChangeParcelStatus(
                                    pbId: parcel.pbId.toString(),
                                    status: "Out For Delivery",
                                  ),
                                );
                              },
                              child: Text(
                                "Out for Delivery",
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
                                      ChangeParcelStatus(
                                        pbId: parcel.pbId.toString(),
                                        status: "Cancelled",
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
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    context.read<OrderDetailsBloc>().add(
                                      ChangeParcelStatus(
                                        pbId: parcel.pbId.toString(),
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
            if (current is ParcelStatusUpdated) return false;
            return true;
          },
          builder: (context, state) {
            if (state is ParcelDetailsLoading) {
              return const Center(child: LoadingWidget());
            }
            if (state is ParcelDetailsSuccess) {
              final parcel = state.order;
              final status = parcel.pbStatus?.toLowerCase();
              return SingleChildScrollView(
                padding: EdgeInsets.all(12.h),
                child: Column(
                  children: [
                    /// GENERAL INFO
                    sectionCard(
                      title:
                          AppLocalizations.of(context)?.generalInfo ??
                          "General Info",
                      children: [
                        SizedBox(height: 10.h),
                        infoRow(
                          AppLocalizations.of(context)?.order ?? "Order Number",
                          parcel.pbNumber ?? "N/A",
                        ),
                        // Text(parcel.rcLat.toString()),
                        // Text(parcel.rcLong.toString()),
                        const Divider(),
                        infoRow(
                          AppLocalizations.of(context)?.orderDate ??
                              "Order Date",
                          DateFormat(
                            'dd MMM yyyy, hh:mm a',
                          ).format(DateTime.parse(parcel.createdAt!)),
                        ),
                        const Divider(),
                        infoRow(
                          AppLocalizations.of(context)?.parcelType ??
                              "Parcel Type",
                          parcel.pbType ?? "N/A",
                          valueColor: AppColors.primaryColor,
                        ),
                        const Divider(),
                        infoRow(
                          AppLocalizations.of(context)?.chargePayBy ??
                              "Charge Pay By",
                          parcel.pbWhoPay ?? "N/A",
                          valueColor: AppColors.primaryColor,
                        ),
                        const Divider(),
                        infoRow(
                          AppLocalizations.of(context)?.status ?? "Status",
                          parcel.pbStatus ?? "N/A",
                          valueColor: AppColors.primaryColor,
                        ),

                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text(
                        //       "Payment Method",
                        //       style: TextStyle(color: Colors.grey, fontSize: 16),
                        //     ),
                        //     Container(
                        //       padding: const EdgeInsets.symmetric(
                        //         horizontal: 12,
                        //         vertical: 6,
                        //       ),
                        //       decoration: BoxDecoration(
                        //         color: Colors.blue[50],
                        //         borderRadius: BorderRadius.circular(10),
                        //       ),
                        //       child: Text(
                        //         parcel.pbPayMethod ?? "N/A",
                        //         style: const TextStyle(
                        //           fontWeight: FontWeight.w500,
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    /// SENDER DETAILS
                    sectionCard(
                      title:
                          AppLocalizations.of(context)?.senderDetails ??
                          "Sender Details",
                      trailing:
                          (status == "assigned" || status == "out for delivery")
                              ? GestureDetector(
                                onTap: () {
                                  GoRouter.of(context).pushNamed(
                                    'delivery-zone-map',
                                    extra: {
                                      'target_lat':
                                          parcel.address?['latitude']
                                              ?.toString() ??
                                          parcel.rcLat.toString(),
                                      'target_long':
                                          parcel.address?['longitude']
                                              ?.toString() ??
                                          parcel.rcLong.toString(),
                                      'target_name':
                                          parcel.user?.name ?? "Sender",
                                      'target_address':
                                          parcel.address?['address'] ??
                                          "Sender Address",
                                      'target_mobile':
                                          parcel.user?.mobile ?? "",
                                      'target_type': 'Sender',
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                ),
                              )
                              : null,
                      children: [
                        SizedBox(height: 10.h),
                        detailRow(Icons.person, parcel.user?.name ?? "N/A"),
                        detailRow(Icons.phone, parcel.user?.mobile ?? "N/A"),
                        detailRow(Icons.email, parcel.user?.email ?? "N/A"),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    sectionCard(
                      title:
                          AppLocalizations.of(context)?.receiverDetails ??
                          "Receiver Details",

                      /// 📍 TRAILING LOCATION ICON
                      trailing:
                          (status == "assigned" || status == "out for delivery")
                              ? GestureDetector(
                                onTap: () {
                                  GoRouter.of(context).pushNamed(
                                    'delivery-zone-map',
                                    extra: {
                                      'target_lat': parcel.rcLat.toString(),
                                      'target_long': parcel.rcLong.toString(),
                                      'target_name':
                                          parcel.rcName ?? "Receiver",
                                      'target_address':
                                          parcel.rcAddress ??
                                          "Receiver Address",
                                      'target_mobile': parcel.rcMobile ?? "",
                                      'target_type': 'Receiver',
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              )
                              : null,

                      children: [
                        SizedBox(height: 10.h),
                        detailRow(Icons.person, parcel.rcName ?? "N/A"),
                        detailRow(Icons.phone, parcel.rcMobile ?? "N/A"),
                        detailRow(Icons.location_on, parcel.rcAddress ?? "N/A"),
                      ],
                    ),

                    const SizedBox(height: 10),

                    sectionCard(
                      title:
                          AppLocalizations.of(context)?.parcelCategory ??
                          "Parcel Category",
                      children: [
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Image.asset(
                              getCategoryImage(parcel?.pbType),
                              width: 40,
                              height: 40,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(parcel.pbType ?? "Parcel"),
                                const SizedBox(height: 2),
                                Text(
                                  AppLocalizations.of(
                                        context,
                                      )?.parcelDeliveryItemms ??
                                      "Parcel delivery item",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),
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
                                  parcel.pbStatus == "pending"
                                      ? "Unpaid"
                                      : "Paid",
                                  style: TextStyle(
                                    color:
                                        parcel.pbStatus == "pending"
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
                                parcel.pbPayMethod.toString(),
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
                            "(+) FCFA ${parcel.pbDeliveryCharge ?? "0"}",
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
                              Text("FCFA ${parcel.pbDeliveryCharge ?? "0"}"),
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

Widget billingRow(String title, String amount) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(color: Colors.black87, fontSize: 16)),
      Text(amount, style: const TextStyle(fontSize: 16)),
    ],
  );
}
