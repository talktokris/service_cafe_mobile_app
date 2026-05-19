import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serve_cafe_mobile/core/navigation/navigation_shell_scope.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    ('Home', Icons.home_outlined, Icons.home, '/home'),
    ('Orders', Icons.receipt_long_outlined, Icons.receipt_long, '/orders'),
    ('Earnings', Icons.trending_up_outlined, Icons.trending_up, '/earnings'),
    ('Wallet', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, '/wallet'),
    ('Account', Icons.person_outline, Icons.person, '/account'),
  ];

  @override
  Widget build(BuildContext context) {
    AppTheme.setStatusBar();
    return NavigationShellScope(
      navigationShell: navigationShell,
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (i) {
            navigationShell.goBranch(
              i,
              initialLocation: i == navigationShell.currentIndex,
            );
          },
          indicatorColor: AppColors.accent.withValues(alpha: 0.2),
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
    );
  }
}
