import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = false,
    this.onBack,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    Widget? leading;
    if (showBack) {
      leading = IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: onBack ?? () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/account');
          }
        },
      );
    }

    return AppBar(
      flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.gradient)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
      centerTitle: true,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: false,
      leadingWidth: showBack ? 48 : 0,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}
