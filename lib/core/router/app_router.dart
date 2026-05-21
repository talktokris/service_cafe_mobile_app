import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/auth/auth_provider.dart';
import 'package:serve_cafe_mobile/screens/account/account_screen.dart';
import 'package:serve_cafe_mobile/screens/account/change_password_screen.dart';
import 'package:serve_cafe_mobile/screens/account/change_referral_screen.dart';
import 'package:serve_cafe_mobile/screens/account/privacy_policy_screen.dart';
import 'package:serve_cafe_mobile/screens/account/profile_screen.dart';
import 'package:serve_cafe_mobile/screens/account/share_referral_screen.dart';
import 'package:serve_cafe_mobile/screens/account/support_screen.dart';
import 'package:serve_cafe_mobile/screens/account/terms_of_service_screen.dart';
import 'package:serve_cafe_mobile/screens/account/transactions_screen.dart';
import 'package:serve_cafe_mobile/screens/auth/forgot_password_screen.dart';
import 'package:serve_cafe_mobile/screens/auth/login_screen.dart';
import 'package:serve_cafe_mobile/screens/auth/register_screen.dart';
import 'package:serve_cafe_mobile/screens/auth/reset_password_screen.dart';
import 'package:serve_cafe_mobile/screens/badges/badges_screen.dart';
import 'package:serve_cafe_mobile/screens/earnings/earnings_screen.dart';
import 'package:serve_cafe_mobile/screens/home/home_screen.dart';
import 'package:serve_cafe_mobile/screens/main/main_shell.dart';
import 'package:serve_cafe_mobile/screens/orders/order_detail_screen.dart';
import 'package:serve_cafe_mobile/screens/orders/orders_screen.dart';
import 'package:serve_cafe_mobile/screens/splash_screen.dart';
import 'package:serve_cafe_mobile/screens/tree/tree_view_screen.dart';
import 'package:serve_cafe_mobile/screens/wallet/wallet_screen.dart';

class AppRouter {
  static GoRouter create(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: auth,
      redirect: (context, state) {
        final loc = state.matchedLocation;
        final loggedIn = auth.isAuthenticated;
        final ready = auth.initialized;

        if (!ready) {
          return loc == '/splash' ? null : '/splash';
        }
        const publicPaths = ['/login', '/register', '/forgot-password', '/reset-password'];
        if (!loggedIn && !publicPaths.any((p) => loc.startsWith(p))) return '/login';
        if (loggedIn && (loc == '/login' || loc == '/splash' || publicPaths.any((p) => loc.startsWith(p)))) return '/home';
        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, s) => RegisterScreen(initialReferralCode: s.uri.queryParameters['ref'])),
        GoRoute(path: '/forgot-password', builder: (_, _) => const ForgotPasswordScreen()),
        GoRoute(
          path: '/reset-password',
          builder: (c, s) => ResetPasswordScreen(initialEmail: s.extra as String? ?? s.uri.queryParameters['email']),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/orders', builder: (_, _) => const OrdersScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/earnings', builder: (_, _) => const EarningsScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/wallet', builder: (_, _) => const WalletScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/account',
                builder: (_, _) => const AccountScreen(),
                routes: [
                  GoRoute(path: 'profile', builder: (_, _) => const ProfileScreen()),
                  GoRoute(path: 'change-password', builder: (_, _) => const ChangePasswordScreen()),
                  GoRoute(path: 'change-referral', builder: (_, _) => const ChangeReferralScreen()),
                  GoRoute(path: 'share-referral', builder: (_, _) => const ShareReferralScreen()),
                  GoRoute(path: 'tree-view', builder: (_, _) => const TreeViewScreen()),
                  GoRoute(path: 'badges', builder: (_, _) => const BadgesScreen()),
                  GoRoute(path: 'transactions', builder: (_, _) => const TransactionsScreen()),
                  GoRoute(path: 'support', builder: (_, _) => const SupportScreen()),
                  GoRoute(path: 'privacy', builder: (_, _) => const PrivacyPolicyScreen()),
                  GoRoute(path: 'terms', builder: (_, _) => const TermsOfServiceScreen()),
                ],
              ),
            ]),
          ],
        ),
        GoRoute(
          path: '/orders/:id',
          builder: (c, s) => OrderDetailScreen(orderId: int.parse(s.pathParameters['id']!)),
        ),
      ],
    );
  }
}
