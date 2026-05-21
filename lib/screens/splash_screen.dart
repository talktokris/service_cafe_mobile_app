import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/auth/auth_provider.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AuthProvider>().bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientVertical),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(opacity: 0.08, child: Image.asset('assets/images/art-logo.png', fit: BoxFit.cover)),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/art-logo.png',
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 28),
                    const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
