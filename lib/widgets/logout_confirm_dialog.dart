import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

Future<bool?> showLogoutConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.logout, color: AppColors.accent),
          SizedBox(width: 10),
          Text('Log Out'),
        ],
      ),
      content: const Text('Are you sure you want to log out of your account?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
          child: const Text('Log Out'),
        ),
      ],
    ),
  );
}
