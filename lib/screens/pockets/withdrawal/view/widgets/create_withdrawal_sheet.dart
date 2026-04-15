import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hyper_local/screens/settings/bloc/profile_bloc/profile_bloc.dart';
import 'package:hyper_local/screens/settings/bloc/profile_bloc/profile_event.dart';
import 'package:hyper_local/screens/settings/bloc/profile_bloc/profile_state.dart';
import '../../../../../utils/widgets/custom_textfield.dart';
import '../../../../system_settings/bloc/system_settings_bloc.dart';
import '../../../../system_settings/bloc/system_settings_state.dart';
import '../../bloc/withdrawal_bloc.dart';
import '../../bloc/withdrawal_event.dart';
import '../../bloc/withdrawal_state.dart';
import '../../../../../utils/currency_formatter.dart';
import 'package:hyper_local/l10n/app_localizations.dart';
import '../../../../../utils/widgets/custom_text.dart';

class CreateWithdrawalSheet extends StatefulWidget {
  const CreateWithdrawalSheet({super.key});

  @override
  State<CreateWithdrawalSheet> createState() => _CreateWithdrawalSheetState();
}

class _CreateWithdrawalSheetState extends State<CreateWithdrawalSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<WithdrawalBloc, WithdrawalState>(
      listener: (context, state) {
        if (state is CreateWithdrawalSuccess) {
          Navigator.of(context).pop(true);
        }
      },
      child: BlocBuilder<WithdrawalBloc, WithdrawalState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    margin: EdgeInsets.only(top: 12.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  // Header
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: theme.colorScheme.primary,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text:
                                    AppLocalizations.of(
                                      context,
                                    )!.requestWithdrawal,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              CustomText(
                                text:
                                    AppLocalizations.of(
                                      context,
                                    )!.withdrawEarningsToBank,
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Available balance
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 8.h,
                    ),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          text: 'Available for Withdrawal',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        // Main available amount (prominent)
                        BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            if (state is ProfileLoaded &&
                                state.profile.user != null) {
                              final available =
                                  state.profile.user!.availableBalance ?? 0;
                              return CustomText(
                                text: CurrencyFormatter.formatAmount(
                                  context,
                                  '$available',
                                ),
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              );
                            }
                            return CustomText(
                              text: CurrencyFormatter.formatAmount(
                                context,
                                '0',
                              ),
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            );
                          },
                        ),

                        SizedBox(height: 8.h),

                        // Breakdown row (Total / Blocked / Available)
                        BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            if (state is ProfileLoaded &&
                                state.profile.user != null) {
                              final user = state.profile.user!;
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildCompactStat(
                                    context,
                                    title: 'Total',
                                    value: user.walletBalance ?? 0,
                                    icon: Icons.wallet,
                                    color: Colors.blue,
                                  ),
                                  _buildCompactStat(
                                    context,
                                    title: 'Blocked',
                                    value: user.blockedBalance ?? 0,
                                    icon: Icons.lock,
                                    color: Colors.orange,
                                  ),
                                  _buildCompactStat(
                                    context,
                                    title: 'Available',
                                    value: user.availableBalance ?? 0,
                                    icon: Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h), // space before amount field
                  // Form
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Amount Field
                          CustomTextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            labelText: AppLocalizations.of(context)!.amount,
                            prefix: BlocBuilder<
                              SystemSettingsBloc,
                              SystemSettingsState
                            >(
                              builder: (context, state) {
                                final currencySymbol =
                                    state is SystemSettingsLoaded
                                        ? state
                                                .settings
                                                .deliveryBoySettings
                                                ?.value
                                                ?.currencySymbol ??
                                            '₹'
                                        : '₹';
                                return CustomText(
                                  text: '$currencySymbol ',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                );
                              },
                            ),
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            borderRadius: 12,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter amount';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid amount';
                              }
                              if (double.parse(value) <= 0) {
                                return 'Amount must be greater than 0';
                              }
                              if (double.parse(value) < 1) {
                                return 'Minimum withdrawal amount is ${CurrencyFormatter.formatAmount(context, '100')}';
                              }
                              final profileState =
                                  context.read<ProfileBloc>().state;
                              double available = 0;
                              if (profileState is ProfileLoaded &&
                                  profileState.profile.user != null) {
                                available =
                                    profileState
                                        .profile
                                        .user!
                                        .availableBalance ??
                                    0;
                              }

                              if (double.parse(value) > available) {
                                return 'Amount cannot exceed available balance (${CurrencyFormatter.formatAmount(context, '$available')})';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          // Note Field
                          CustomTextFormField(
                            controller: _noteController,
                            maxLines: 3,
                            labelText:
                                AppLocalizations.of(context)!.noteOptional,
                            hintText:
                                AppLocalizations.of(
                                  context,
                                )!.addNoteForWithdrawal,
                            textStyle: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface,
                            ),
                            borderRadius: 12,
                          ),
                          SizedBox(height: 24),
                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    side: BorderSide(
                                      color: theme.colorScheme.outline
                                          .withValues(alpha: 0.3),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: CustomText(
                                    text: AppLocalizations.of(context)!.cancel,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      state is WithdrawalLoading
                                          ? null
                                          : _submitWithdrawal,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child:
                                      state is WithdrawalLoading
                                          ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(
                                                        theme
                                                            .colorScheme
                                                            .onPrimary,
                                                      ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              CustomText(
                                                text:
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.submitting,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    theme.colorScheme.onPrimary,
                                              ),
                                            ],
                                          )
                                          : CustomText(
                                            text:
                                                AppLocalizations.of(
                                                  context,
                                                )!.submitRequest,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitWithdrawal() {
    if (_formKey.currentState!.validate()) {
      final amountText = _amountController.text.trim();
      final amount = double.tryParse(amountText);

      if (amount == null) return; // Shouldn't happen due to validator

      // Get current profile state
      final profileState = context.read<ProfileBloc>().state;

      double availableBalance = 0;
      if (profileState is ProfileLoaded && profileState.profile.user != null) {
        availableBalance = profileState.profile.user!.availableBalance ?? 0;
      }

      // Extra safety check before dispatching event
      if (amount > availableBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Amount cannot exceed available balance (${CurrencyFormatter.formatAmount(context, '$availableBalance')})',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final note = _noteController.text.trim();

      context.read<WithdrawalBloc>().add(
        CreateWithdrawal(amount: amount, note: note),
      );
    }
  }

  Widget _buildCompactStat(
    BuildContext context, {
    required String title,
    required double value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20.sp, color: color),
        SizedBox(height: 4.h),
        CustomText(
          text: CurrencyFormatter.formatAmount(context, '$value'),
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        CustomText(
          text: title,
          fontSize: 11.sp,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ],
    );
  }
}
