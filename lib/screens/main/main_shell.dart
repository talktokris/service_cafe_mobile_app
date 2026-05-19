import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serve_cafe_mobile/core/navigation/navigation_shell_scope.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    ('Home', Icons.home_outlined, Icons.home_rounded, '/home'),
    ('Orders', Icons.receipt_long_outlined, Icons.receipt_long_rounded, '/orders'),
    ('Earnings', Icons.trending_up_outlined, Icons.trending_up_rounded, '/earnings'),
    ('Wallet', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, '/wallet'),
    ('Account', Icons.person_outline_rounded, Icons.person_rounded, '/account'),
  ];

  @override
  Widget build(BuildContext context) {
    AppTheme.setStatusBar();
    return NavigationShellScope(
      navigationShell: navigationShell,
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (i) {
                navigationShell.goBranch(
                  i,
                  initialLocation: i == navigationShell.currentIndex,
                );
              },
              indicatorColor: AppColors.accent.withValues(alpha: 0.14),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                for (final t in _tabs)
                  NavigationDestination(
                    icon: Icon(t.$2),
                    selectedIcon: Icon(t.$3, color: AppColors.accent),
                    label: t.$1,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
