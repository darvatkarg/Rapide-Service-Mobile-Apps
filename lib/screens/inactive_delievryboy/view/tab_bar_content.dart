import 'package:flutter/material.dart';
import 'package:hyper_local/screens/feed_page/widgets/available_orders/available_orders_section.dart';

import 'package:hyper_local/screens/inactive_delievryboy/view/ongoing_orders.dart';
import 'package:hyper_local/screens/inactive_delievryboy/view/ongoing_parcels.dart';

class TabContentSection extends StatelessWidget {
  final TabController tabController;
  final bool isDeliveryBoyActive;
  // final bool isDarkTheme;

  const TabContentSection({
    super.key,
    required this.tabController,
    required this.isDeliveryBoyActive,
    // required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TabBarView(
        controller: tabController,
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          AvailableOrdersSection(isDeliveryBoyActive: isDeliveryBoyActive),
          // OngoingOrders(),
          OngoingParcels(isDeliveryBoyActive: isDeliveryBoyActive),
          // AvailableOrdersSection(isDeliveryBoyActive: isDeliveryBoyActive),
          // MyOrdersSection(
          //   isDarkTheme: isDarkTheme,
          //   isDeliveryBoyActive: isDeliveryBoyActive,
          // ),
          // ReturnOrdersSection(isDeliveryBoyActive: isDeliveryBoyActive),
          // MyPickupsSection(
          //   isDeliveryBoyActive: isDeliveryBoyActive,
          // ), // ← 4th Tab
        ],
      ),
    );
  }
}
