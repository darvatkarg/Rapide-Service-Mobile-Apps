// ignore_for_file: empty_catches, deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/screens/settings/bloc/profile_bloc/profile_bloc.dart';
import 'package:hyper_local/screens/settings/bloc/profile_bloc/profile_state.dart';
import 'package:hyper_local/screens/settings/model/profile_model.dart';
import 'package:hyper_local/utils/widgets/custom_scaffold.dart';
import 'package:hyper_local/utils/widgets/loading_widget.dart';
import 'package:intl/intl.dart';
import '../../../utils/widgets/custom_button.dart';
import '../../../utils/widgets/custom_card.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../feed_page/widgets/header_section/home_header_section.dart';
import '../earnings/bloc/earnings_bloc.dart';
import '../earnings/bloc/earnings_event.dart';
import '../earnings/bloc/earnings_state.dart';
import '../earnings/model/earnings_model.dart';

import '../earnings/repo/earnings_repo.dart';
import '../../../utils/currency_formatter.dart';
import '../../feed_page/bloc/deliveryboy_status_update_bloc/deliveryboy_status_bloc.dart';
import '../../feed_page/bloc/deliveryboy_status_update_bloc/deliveryboy_status_event.dart';
import '../../feed_page/bloc/deliveryboy_status_update_bloc/deliveryboy_status_state.dart';
import '../../../l10n/app_localizations.dart';

import '../../../../config/colors.dart';

class PocketsPage extends StatefulWidget {
  const PocketsPage({super.key});

  @override
  State<PocketsPage> createState() => _PocketsPageState();
}

class _PocketsPageState extends State<PocketsPage> {
  late EarningsBloc _earningsBloc;

  @override
  void initState() {
    super.initState();
    // Create the bloc instance
    _earningsBloc = EarningsBloc(EarningsRepo(), context: context);
    // Check delivery boy status first, then conditionally make API calls
    context.read<DeliveryBoyStatusBloc>().add(CheckApiStatus());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Sync with current delivery boy status when page becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryBoyStatusBloc>().add(CheckApiStatus());
    });
  }

  @override
  void dispose() {
    _earningsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show exit confirmation dialog
        return await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    AppLocalizations.of(context)?.exitApp ?? "Exit App",
                  ),
                  content: Text(
                    AppLocalizations.of(context)?.exitAppConfirmation ??
                        "Are you sure you want to exit the app?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        AppLocalizations.of(context)?.cancel ?? "Cancel",
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(AppLocalizations.of(context)?.exit ?? "Exit"),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },
      child: MultiBlocProvider(
        providers: [BlocProvider(create: (context) => _earningsBloc)],
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: SafeArea(
            child: CustomScaffold(
              body: Stack(
                children: [
                  // Main pockets content (always visible)
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10.0.w,
                      right: 10.0.w,
                      top: 5.0.h,
                      bottom: 16.0.h, // Keep padding to avoid overlap with FAB
                    ),
                    child: Column(
                      children: [
                        // Header (always visible)
                        BlocBuilder<
                          DeliveryBoyStatusBloc,
                          DeliveryBoyStatusState
                        >(
                          builder: (context, statusState) {
                            bool currentStatus = false; // Default to inactive
                            if (statusState is DeliveryBoyStatusLoaded) {
                              currentStatus = statusState.isOnline;
                            }

                            return HomeHeaderSection(
                              handleToggle: () {
                                try {
                                  final bloc =
                                      context.read<DeliveryBoyStatusBloc>();
                                  final newValue = !currentStatus;
                                  bloc.add(ToggleStatus(newValue));
                                } catch (e) {}
                              },
                            );
                          },
                        ),
                        SizedBox(height: 16.h),
                        // Content
                        Expanded(child: _buildPocketsView()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsSection(ProfileModel profile) {
    return Column(
      children: [
        /// Wallet Card (keep as it is)
        GestureDetector(
          onTap: () {
            context.push('/earnings');
          },
          child: CustomCard(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.green,
                  size: 50.sp,
                ),
                const SizedBox(height: 12),
                Text(
                  '${profile.user?.walletBalance ?? 0}',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)?.walletBalance ??
                      "Wallet Balance",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  // width: 220.w,
                  height: 45.h,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet, size: 18),
                        SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)?.topUpNow ??
                              "Top Up Now",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 12.h),

        /// Title
        Align(
          alignment: Alignment.centerLeft,
          child: CustomText(
            text:
                AppLocalizations.of(context)?.walletHistory ?? "Wallet History",
            fontSize: 16.sp,
          ),
        ),

        SizedBox(height: 12.h),

        /// 🔥 API DATA HERE
        Expanded(
          child: BlocBuilder<EarningsBloc, EarningsState>(
            bloc: _earningsBloc,
            builder: (context, state) {
              if (state is TopUpHistoryLoading) {
                return const Center(child: LoadingWidget());
              }

              if (state is EarningsError) {
                return Center(child: Text(state.message));
              }

              if (state is MyHistoryTopUpsLoaded) {
                final list = state.historyTopUps;

                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)?.noRecordFound ??
                          "No history found",
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    String _formatDate(String? date) {
                      if (date == null) return "";

                      final parsed = DateTime.tryParse(date);
                      if (parsed == null) return date;

                      return DateFormat('MMM dd, yyyy').format(parsed);
                    }

                    return CustomCard(
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// LEFT SIDE
                          Expanded(
                            // 👈 VERY IMPORTANT
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.local_shipping_outlined,
                                    color: Colors.grey.shade600,
                                  ),
                                ),

                                SizedBox(width: 12.w),

                                /// 👇 FIX HERE
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.description.toString(),
                                        style: TextStyle(fontSize: 14.sp),
                                        maxLines: 2, // 👈 prevents overflow
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _formatDate(item.createdAt),
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// RIGHT SIDE (AMOUNT)
                          Text(
                            "FCFA ${item.amount}",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color:
                                  (item.amount?.contains('-') ?? false)
                                      ? Colors.red
                                      : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  // Widget _buildEarningsStats(EarningsStatisticsModel stats) {
  //   return CustomCard(
  //     padding: EdgeInsets.all(16.w),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         CustomText(
  //           text: AppLocalizations.of(context)!.earnings,

  //           fontSize: 14.sp,
  //           fontWeight: FontWeight.w600,
  //         ),
  //         SizedBox(height: 16.h),
  //         Row(
  //           children: [
  //             Expanded(
  //               child: _buildStatItem(
  //                 AppLocalizations.of(context)!.pending,
  //                 CurrencyFormatter.formatAmount(
  //                   context,
  //                   '${stats.pendingEarnings ?? 0}',
  //                 ),
  //                 Icons.pending,
  //                 Colors.orange,
  //               ),
  //             ),
  //             SizedBox(width: 16.w),
  //             Expanded(
  //               child: _buildStatItem(
  //                 AppLocalizations.of(context)!.paid,
  //                 CurrencyFormatter.formatAmount(
  //                   context,
  //                   '${stats.paidEarnings ?? 0}',
  //                 ),
  //                 Icons.check_circle,
  //                 Colors.green,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildUserBalance(ProfileModel profile) {
  //   return CustomCard(
  //     padding: EdgeInsets.all(16.w),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         CustomText(
  //           text: AppLocalizations.of(context)!.balance,

  //           fontSize: 14.sp,
  //           fontWeight: FontWeight.w600,
  //         ),
  //         SizedBox(height: 16.h),
  //         Row(
  //           children: [
  //             Expanded(
  //               child: _buildStatItem(
  //                 'Total',
  //                 CurrencyFormatter.formatAmount(
  //                   context,
  //                   '${profile.user?.walletBalance ?? 0}',
  //                 ),
  //                 Icons.money,
  //                 Colors.blue,
  //               ),
  //             ),
  //             SizedBox(width: 16.w),
  //             Expanded(
  //               child: _buildStatItem(
  //                 'Blocked',
  //                 CurrencyFormatter.formatAmount(
  //                   context,
  //                   '${profile.user?.blockedBalance ?? 0}',
  //                 ),
  //                 Icons.pending,
  //                 Colors.orange,
  //               ),
  //             ),
  //             SizedBox(width: 16.w),
  //             Expanded(
  //               child: _buildStatItem(
  //                 'Available',
  //                 CurrencyFormatter.formatAmount(
  //                   context,
  //                   '${profile.user?.availableBalance ?? 0}',
  //                 ),
  //                 Icons.check_circle,
  //                 Colors.green,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildEarningsErrorState(String message) {
  //   return CustomCard(
  //     padding: EdgeInsets.all(16.w),
  //     child: Column(
  //       children: [
  //         Icon(
  //           Icons.error_outline,
  //           color: Theme.of(context).colorScheme.error,
  //           size: 24.sp,
  //         ),
  //         SizedBox(height: 8.h),
  //         CustomText(
  //           text: AppLocalizations.of(context)!.somethingWentWrong,

  //           fontSize: 14.sp,
  //           fontWeight: FontWeight.w600,
  //           textAlign: TextAlign.center,
  //         ),
  //         // SizedBox(height: 4.h),
  //         // CustomText(
  //         //   text: message,
  //         //
  //         //   fontSize: 12.sp,
  //         //   color: Theme.of(context).colorScheme.error,
  //         //   textAlign: TextAlign.center,
  //         // ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStatItem(
  //   String title,
  //   String value,
  //   IconData icon,
  //   Color color,
  // ) {
  //   return Column(
  //     children: [
  //       Container(
  //         padding: EdgeInsets.all(8.w),
  //         decoration: BoxDecoration(
  //           color: color.withValues(alpha: 0.1),
  //           borderRadius: BorderRadius.circular(8.r),
  //         ),
  //         child: Icon(icon, color: color, size: 16.sp),
  //       ),
  //       SizedBox(height: 8.h),
  //       CustomText(
  //         text: value,
  //         fontSize: 16.sp,
  //         fontWeight: FontWeight.bold,
  //         color: color,
  //       ),
  //       CustomText(
  //         text: title,
  //         fontSize: 12.sp,
  //         color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildPocketsView() {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // Always show the pockets content regardless of delivery boy status
    return _buildPocketsContent(isDarkTheme);
  }

  Widget _buildPocketsContent(bool isDarkTheme) {
    // Make API calls to fetch earnings data
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _earningsBloc.add(FetchEarningsStats());
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _earningsBloc.add(TopUpHistory(page: 1, perPage: 10));
    });

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return _buildEarningsSection(state.profile);
        }
        if (state is ProfileLoading) {
          return const Center(child: LoadingWidget());
        }
        return const Center(child: Text("Failed to load profile"));
      },
    );
    //
  }

  String _getCurrentWeekRange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final startMonth = _getMonthName(startOfWeek.month);
    final endMonth = _getMonthName(endOfWeek.month);

    if (startMonth == endMonth) {
      return '${AppLocalizations.of(context)!.earnings}: ${startOfWeek.day} $startMonth - ${endOfWeek.day} $endMonth';
    } else {
      return '${AppLocalizations.of(context)!.earnings}: ${startOfWeek.day} $startMonth - ${endOfWeek.day} $endMonth';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
