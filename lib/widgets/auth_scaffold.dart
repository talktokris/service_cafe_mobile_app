import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.showBack = false,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                decoration: const BoxDecoration(
                  gradient: AppColors.gradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    if (showBack)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset('assets/images/logo.png', height: 72),
                    ),
                    const SizedBox(height: 16),
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(subtitle!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ],
                ),
              ),
              Padding(padding: const EdgeInsets.all(24), child: child),
            ],
          ),
        ),
      ),
    );
  }
}
