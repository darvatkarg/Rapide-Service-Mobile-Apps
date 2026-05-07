import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/router/app_routes.dart';

import 'package:hyper_local/screens/my_orders/bloc/download_invoice/download_invoice_bloc.dart';
import 'package:hyper_local/screens/my_orders/bloc/get_my_order/get_my_order_bloc.dart';
import 'package:hyper_local/screens/my_orders/bloc/get_my_order/get_my_order_event.dart';
import 'package:hyper_local/screens/my_orders/bloc/return_order_item/return_order_item_bloc.dart';
import 'package:hyper_local/screens/my_orders/model/order_detail_model.dart';
import 'package:hyper_local/screens/my_orders/widgets/return_dialog.dart';
import 'package:hyper_local/screens/product_detail_page/bloc/product_feedback/product_feedback_bloc.dart';
import 'package:hyper_local/utils/widgets/animated_button.dart';
import 'package:hyper_local/utils/widgets/custom_button.dart';
import 'package:hyper_local/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:hyper_local/utils/widgets/custom_refresh_indicator.dart';

import 'package:hyper_local/utils/widgets/custom_scaffold.dart';
import 'package:hyper_local/utils/widgets/custom_toast.dart';
import 'package:hyper_local/utils/widgets/whole_page_progress.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/helper.dart';
import '../../../config/theme.dart';
import '../../../utils/widgets/dialog_box_animation.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/order_detail/order_detail_bloc.dart';

class OrderDetailPage extends StatefulWidget {
  final String id;
  const OrderDetailPage({super.key, required this.id});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    apiCall();
  }

  // Future<void> apiCall() async {
  //   context
  //       .read<OrderDetailBloc>()
  //       .add(FetchOrderDetail(orderSlug: widget.orderSlug));
  // }

  Future<void> apiCall() async {
    context.read<OrderDetailBloc>().add(FetchParcelOrderDetail(id: widget.id));
  }

  // Future<void> _launchPdf(String pdfUrl) async {
  //   final Uri url = Uri.parse(pdfUrl);

  //   if (!await canLaunchUrl(url)) {
  //     log('Cannot launch URL: $url');
  //     return;
  //   }

  //   await launchUrl(
  //     url,
  //     mode: LaunchMode.externalApplication,
  //   );
  // }

  // void _showReturnDialog(
  //     List<OrderItems> items, String orderSlug, bool isDelivered) {
  //   openSlideUpDialog(
  //       context,
  //       ReturnItemsDialog(
  //           items: items, orderSlug: orderSlug, isDelivered: isDelivered));
  // }

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
    return MultiBlocListener(
      listeners: [
        BlocListener<ReturnOrderItemBloc, ReturnOrderItemState>(
            listener: (context, ReturnOrderItemState state) {
          if (state is ReturnOrderItemSuccess) {
            // ToastManager.show(
            //   context: context,
            //   message: state.message,
            // );
            apiCall();
            context.read<GetMyOrderBloc>().add(RefreshMyOrders());
          } else if (state is ReturnOrderItemFailed) {
            ToastManager.show(
              context: context,
              message: state.error,
            );
          }
        })
      ],
      child: BlocConsumer<DownloadInvoiceBloc, DownloadInvoiceState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Stack(
            children: [
              Builder(builder: (context) {
                return CustomScaffold(
                  showViewCart: false,
                  title: AppLocalizations.of(context)!.orderSummary,
                  showAppBar: true,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainer,
        
                  body: CustomRefreshIndicator(
                    onRefresh: apiCall,
                    child: BlocBuilder<OrderDetailBloc, OrderDetailState>(
                      builder: (context, state) {
                        if (state is GetMyParcelOrderDetail) {
                          final orderData = state.parcelDetails.parcel;
                          final status = orderData!.status!.toLowerCase();

                          final deliveryBoyId =
                              orderData.deliveryAssignments.isNotEmpty
                                  ? orderData
                                      .deliveryAssignments.first.deliveryBoyId
                                  : null;
                          print("Order Detail Data: ${status}");
                          print("delivery boy id: ${deliveryBoyId}");

                          return SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.all(12.0.h),
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),

                                  // Text(orderData.toString()),
                                  sectionCard(
                                    title: AppLocalizations.of(context)
                                            ?.generalInfo ??
                                        "General Info",
                                    children: [
                                      SizedBox(height: 10.h),
                                      infoRow(
                                        AppLocalizations.of(context)
                                                ?.orderDate ??
                                            'Order Date',
                                        DateFormat('dd MMM yyyy, hh:mm a')
                                            .format(DateTime.parse(
                                                orderData!.createdAt!)),
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)
                                                    ?.paymentMethod ??
                                                "Payment Method",
                                            // style: TextStyle(
                                            //   color: AppTheme.primaryColor,
                                            //   fontWeight: FontWeight.w500,
                                            // ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              orderData.payMethod ?? '',
                                              style: TextStyle(
                                                color: AppTheme.primaryColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      const Divider(),
                                      infoRow(
                                        AppLocalizations.of(context)?.orderBy ??
                                            "Order By",
                                        orderData?.pbType ?? '',
                                        valueColor: AppTheme.primaryColor,
                                      ),
                                      const Divider(),
                                      infoRow(
                                        AppLocalizations.of(context)
                                                ?.chargePayBy ??
                                            "Charge Pay By",
                                        orderData?.whoPay ?? '',
                                        valueColor: AppTheme.primaryColor,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  /// SENDER DETAILS
                                  sectionCard(
                                    title: AppLocalizations.of(context)
                                            ?.senderDetails ??
                                        "Sender Details",
                                    children: [
                                      SizedBox(height: 10.h),
                                      detailRow(Icons.person,
                                          orderData?.user?.name ?? ""),
                                      detailRow(Icons.phone,
                                          orderData?.user?.mobile ?? ""),
                                      detailRow(Icons.email,
                                          orderData?.user?.email ?? ""),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  /// RECEIVER DETAILS
                                  sectionCard(
                                    title: AppLocalizations.of(context)
                                            ?.receiverDetails ??
                                        "Receiver Details",
                                    trailing: (status == "out for delivery")
                                        ? GestureDetector(
                                            onTap: () {
                                              print(
                                                " Receiver Location: Lat=${orderData.receiverLat}, Long=${orderData.receiverLong}",
                                              );

                                              GoRouter.of(context).pushNamed(
                                                'delivery-zone-map',
                                                extra: {
                                                  'rc_lat': orderData
                                                      .receiverLat
                                                      .toString(),
                                                  'rc_long': orderData
                                                      .receiverLong
                                                      .toString(),
                                                  'driver_id': orderData
                                                          .deliveryAssignments
                                                          .isNotEmpty
                                                      ? orderData
                                                          .deliveryAssignments
                                                          .first
                                                          .deliveryBoyId
                                                          .toString()
                                                      : "",
                                                },
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryColor
                                                    .withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.location_on,
                                                color: AppTheme.primaryColor,
                                                size: 20,
                                              ),
                                            ),
                                          )
                                        : null,
                                    children: [
                                      SizedBox(height: 10.h),
                                      detailRow(Icons.person,
                                          orderData?.receiverName ?? ""),
                                      detailRow(Icons.phone,
                                          orderData?.receiverMobile ?? ""),
                                      detailRow(Icons.email, ""),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  sectionCard(
                                    title: AppLocalizations.of(context)
                                            ?.parcelCategory ??
                                        "Parcel Category",
                                    children: [
                                      SizedBox(height: 10.h),
                                      Row(
                                        children: [
                                          Image.asset(
                                            getCategoryImage(orderData?.pbType),
                                            width: 40,
                                            height: 40,
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                orderData?.pbType ?? "",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              const Text(
                                                "Parcel delivery item",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 13,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),

                                  const SizedBox(height: 10),
                                  Container(
                                    // margin: const EdgeInsets.symmetric(
                                    //     horizontal: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /// PAYMENT DETAILS HEADER
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)
                                                      ?.paymentDetails ??
                                                  "Payment Details",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: orderData?.status ==
                                                        "completed"
                                                    ? Colors.green
                                                        .withOpacity(.15)
                                                    : Colors.red
                                                        .withOpacity(.15),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                orderData?.status == "completed"
                                                    ? "Paid"
                                                    : "Unpaid",
                                                style: TextStyle(
                                                  color: orderData?.status ==
                                                          "completed"
                                                      ? Colors.green
                                                      : Colors.red,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),

                                        const SizedBox(height: 12),
                                        const Divider(),

                                        const SizedBox(height: 10),

                                        /// PAYMENT METHOD
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.payments_outlined,
                                                    size: 20),
                                                const SizedBox(width: 10),
                                                Text(
                                                  orderData?.payMethod ?? "",
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                )
                                              ],
                                            ),
                                            Text(
                                              "FCFA ${orderData?.deliveryCharge ?? "0"}",
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            )
                                          ],
                                        ),

                                        const SizedBox(height: 25),

                                        /// BILLING SUMMARY TITLE
                                        Text(
                                          AppLocalizations.of(context)
                                                  ?.billingSummary ??
                                              "Billing Summary",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),

                                        const SizedBox(height: 15),

                                        /// DELIVERY FEE
                                        billingRow(
                                          AppLocalizations.of(context)
                                                  ?.deliveryFee ??
                                              "Delivery Fee",
                                          "(+) FCFA ${orderData?.deliveryCharge ?? "0"}",
                                        ),

                                        const SizedBox(height: 10),

                                        // /// DELIVERY TIPS
                                        // billingRow(
                                        //     "Delivery Man Tips", "(+) \$ 0.00"),

                                        // const SizedBox(height: 10),

                                        // /// TAX
                                        // billingRow("Vat/Tax", "(+) \$ 19.00"),

                                        // const SizedBox(height: 10),

                                        // /// ADDITIONAL CHARGE
                                        // billingRow(
                                        //     "Additional Charge", "(+) \$ 0.00"),

                                        // const SizedBox(height: 15),
                                        const Divider(),

                                        const SizedBox(height: 10),

                                        /// TOTAL AMOUNT
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)
                                                          ?.totalAmount ??
                                                      "Total Amount",
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red
                                                        .withOpacity(.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: const Text(
                                                    "Due",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            Text(
                                              "FCFA ${orderData?.deliveryCharge ?? "0"}",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                  // OrderItemsCard(
                                  //   items: orderData!.items,
                                  //   totalItems:
                                  //       orderData.items.length.toString(),
                                  //   priceColor: Colors.black,
                                  //   originalPriceColor: Colors.grey[500],
                                  // ),
                                  // if (orderData.status == 'delivered') ...[
                                  //   rateWidget(orderData.id!, orderData.slug!,
                                  //       orderData),
                                  //   SizedBox(height: 10.h),
                                  // ],
                                  // trackDeliveryAndReturnProduct(
                                  //   orderSlug: orderData.slug!,
                                  //   items: orderData.items,
                                  //   isDelivered: orderData.status == 'delivered'
                                  //       ? true
                                  //       : false,
                                  //   isDeliveryBoyAssigned:
                                  //       orderData.deliveryBoyId != null,
                                  // ),
                                  // SizedBox(height: 10.h),
                                  // OrderNoteDisplayWidget(
                                  //   orderNote: orderData.orderNote ?? '',
                                  // ),
                                  // // SizedBox(height: 10.h),
                                  // BillSummaryWidget(
                                  //   itemsOriginalPrice:
                                  //       double.parse(orderData.totalPayable!),
                                  //   itemsDiscountedPrice:
                                  //       double.parse(orderData.subtotal!),
                                  //   itemsSavings: 0,
                                  //   deliveryChargeOriginal:
                                  //       double.parse(orderData.deliveryCharge!),
                                  //   handlingCharge: double.parse(
                                  //       orderData.handlingCharges!),
                                  //   perStoreDropOffFees: double.parse(
                                  //       orderData.perStoreDropOffFee!),
                                  //   grandTotal:
                                  //       double.parse(orderData.finalTotal!),
                                  //   totalSavings: 0,
                                  //   isFromOrderDetail: true,
                                  //   downloadInvoice: () {
                                  //     _launchPdf(orderData.invoice!);
                                  //   },
                                  //   promoCode: orderData.promoCode,
                                  //   promoDiscount: double.parse(
                                  //       orderData.promoDiscount ?? '0.0'),
                                  // ),
                                  // SizedBox(height: 10.h),
                                  // OrderDetailCard(
                                  //   orderId: orderData.id.toString(),
                                  //   paymentMethod: orderData.paymentMethod!,
                                  //   deliveryAddress:
                                  //       orderData.shippingAddress1!,
                                  //   orderDate: orderData.createdAt!,
                                  // ),
                                ],
                              ),
                            ),
                          );
                        } else if (state is OrderDetailLoading) {
                          return CustomCircularProgressIndicator();
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ),
                );
              }),
              if (state is DownloadInvoiceLoading) WholePageProgress(),
            ],
          );
        },
      ),
    );
  }

  Widget billingRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 16,
          ),
        )
      ],
    );
  }

  Widget sectionCard({
    required String title,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      // margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          // const SizedBox(height: 15),
          ...children
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
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
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

  Widget rateWidget(int orderId, String orderSlug, OrderDetailData? orderData) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Builder(builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Text(
                  l10n?.howWasYourShoppingExperience ??
                      'How was your shopping experience?',
                  style: TextStyle(fontSize: 12.sp),
                );
              }),
            ),
            SizedBox(width: 5.w),
            CustomButton(
              onPressed: () async {
                final storeMap = {
                  "orderSlug": orderSlug,
                  "orderId": orderId,
                };

                final result = await GoRouter.of(context).push(
                  AppRoutes.rateYourExp,
                  extra: storeMap,
                );

                if (result == true && mounted) {
                  context
                      .read<ProductFeedbackBloc>()
                      .add(ResetProductFeedback());

                  await apiCall();

                  if (mounted) {
                    final l10n = AppLocalizations.of(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n?.orderDetailsRefreshed ??
                            'Order details refreshed'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                }
              },
              child: Builder(builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Text(l10n?.rateOrder ?? 'Rate Order');
              }),
            )
          ],
        ),
      ),
    );
  }

  // Widget trackDeliveryAndReturnProduct({
  //   required String orderSlug,
  //   required List<OrderItems> items,
  //   required bool isDelivered,
  //   required bool isDeliveryBoyAssigned,
  // }) {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: AnimatedButton(
  //           onTap: () {
  //             _showReturnDialog(items, orderSlug, isDelivered);
  //           },
  //           child: Container(
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(12.r),
  //               color: isDarkMode(context)
  //                   ? Theme.of(context).colorScheme.surface
  //                   : Colors.white,
  //             ),
  //             margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
  //             child: Padding(
  //               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Text(
  //                     textAlign: TextAlign.center,
  //                     isDelivered
  //                         ? AppLocalizations.of(context)!.returnItem
  //                         : AppLocalizations.of(context)!.cancelItem,
  //                     style: TextStyle(
  //                         fontSize: isTablet(context) ? 18 : 12.sp,
  //                         color: Colors.red),
  //                   ),
  //                   Icon(
  //                     Directionality.of(context) == TextDirection.ltr
  //                         ? TablerIcons.chevron_right
  //                         : TablerIcons.chevron_left,
  //                     size: 20,
  //                     color: Colors.red,
  //                   )
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //       if (!isDelivered && isDeliveryBoyAssigned) ...[
  //         SizedBox(
  //           width: 12.w,
  //         ),
  //         Expanded(
  //           child: AnimatedButton(
  //             onTap: () {
  //               GoRouter.of(context).push(AppRoutes.deliveryTracking,
  //                   extra: {'order-slug': orderSlug});
  //             },
  //             child: Card(
  //               elevation: 0,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12.r),
  //               ),
  //               margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
  //               child: Padding(
  //                 padding:
  //                     EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Row(
  //                       children: [
  //                         SizedBox(width: 10),
  //                         Text(
  //                           AppLocalizations.of(context)!.trackYourDelivery,
  //                           style: TextStyle(
  //                             fontSize: isTablet(context) ? 18 : 12.sp,
  //                             color: AppTheme.primaryColor,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ],
  //   );
  // }
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
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 15),
          )
        ],
      ),
    );
  }
}
