import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/auth/auth_provider.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/utils/format.dart';
import 'package:serve_cafe_mobile/widgets/delete_account_dialog.dart';
import 'package:serve_cafe_mobile/widgets/logout_confirm_dialog.dart';
import 'package:serve_cafe_mobile/widgets/member_type_chip.dart';
import 'package:serve_cafe_mobile/widgets/menu_section_card.dart';
import 'package:serve_cafe_mobile/widgets/pull_to_refresh.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Future<void> _refresh() async {
    await context.read<AuthProvider>().fetchMe();
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showLogoutConfirmDialog(context);
    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) context.go('/login');
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final deleted = await showDeleteAccountDialog(context);
    if (!context.mounted || deleted != true) return;

    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final topPadding = MediaQuery.paddingOf(context).top;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: topPadding + 12,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(gradient: AppColors.gradient),
            child: const Text(
              'My Account',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: PullToRefresh.list(
              onRefresh: _refresh,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _ProfileCard(user: user),
                const SizedBox(height: 20),
                MenuSectionCard(
                  title: 'Account',
                  children: [
                    MenuTile(
                      icon: Icons.person_outline,
                      label: 'Profile',
                      onTap: () => context.push('/account/profile'),
                    ),
                    MenuTile(
                      icon: Icons.lock_outline,
                      label: 'Change Password',
                      onTap: () => context.push('/account/change-password'),
                    ),
                    MenuTile(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Bank & eWallet Setup',
                      onTap: () => context.push('/account/bank-ewallet-setup'),
                    ),
                    MenuTile(
                      icon: Icons.edit_outlined,
                      label: 'Change Referral',
                      onTap: () => context.push('/account/change-referral'),
                      showDivider: false,
                    ),
                  ],
                ),
                MenuSectionCard(
                  title: 'Network',
                  children: [
                    MenuTile(
                      icon: Icons.share_outlined,
                      label: 'Share Referral',
                      onTap: () => context.push('/account/share-referral'),
                    ),
                    MenuTile(
                      icon: Icons.account_tree_outlined,
                      label: 'Tree View',
                      onTap: () => context.push('/account/tree-view'),
                    ),
                    MenuTile(
                      icon: Icons.military_tech_outlined,
                      label: 'Badges',
                      onTap: () => context.push('/account/badges'),
                      showDivider: false,
                    ),
                  ],
                ),
                MenuSectionCard(
                  title: 'Finance',
                  children: [
                    MenuTile(
                      icon: Icons.receipt_long_outlined,
                      label: 'Transactions',
                      onTap: () => context.push('/account/transactions'),
                      showDivider: false,
                    ),
                  ],
                ),
                MenuSectionCard(
                  title: 'Orders',
                  children: [
                    MenuTile(
                      icon: Icons.pin_outlined,
                      label: 'My Order OTP',
                      onTap: () => context.push('/account/order-otp'),
                      showDivider: false,
                    ),
                  ],
                ),
                MenuSectionCard(
                  title: 'Help',
                  children: [
                    MenuTile(
                      icon: Icons.support_agent_outlined,
                      label: 'Support',
                      onTap: () => context.push('/account/support'),
                      showDivider: false,
                    ),
                  ],
                ),
                MenuSectionCard(
                  title: 'Session',
                  children: [
                    MenuTile(
                      icon: Icons.person_remove_outlined,
                      label: 'Delete Account',
                      iconColor: AppColors.danger,
                      textColor: AppColors.danger,
                      onTap: () => _confirmDeleteAccount(context),
                    ),
                    MenuTile(
                      icon: Icons.logout,
                      label: 'Log Out',
                      iconColor: AppColors.accent,
                      textColor: AppColors.accent,
                      onTap: () => _confirmLogout(context),
                      showDivider: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final initial = (user?.name?.isNotEmpty == true ? user!.name![0] : 'M')
        .toUpperCase();

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.accent.withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: CircleAvatar(
                radius: 42,
                backgroundColor: AppColors.surface,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              user?.name ?? 'Member',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                MemberTypeChip(isPaid: user?.isPaid ?? false),
                if (user?.referralCode != null &&
                    user!.referralCode!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.link,
                          size: 14,
                          color: AppColors.primary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          user.referralCode!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.accent,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Purchase Wallet',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          formatNrs(user?.walletBalance ?? 0),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
