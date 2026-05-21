import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/auth/auth_provider.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

Future<void> showDeleteAccountDialog(BuildContext context) async {
  final confirmCtrl = TextEditingController();
  var loading = false;
  String? error;

  await showDialog<void>(
    context: context,
    barrierDismissible: !loading,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        final canConfirm = confirmCtrl.text == 'Delete' && !loading;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.person_remove_outlined, color: AppColors.danger),
              SizedBox(width: 10),
              Text('Delete Account'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'This permanently removes your personal information (name, email, phone, address). '
                  'You will not be able to sign in again. Your account record is retained for business records only.',
                  style: TextStyle(height: 1.4),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmCtrl,
                  enabled: !loading,
                  decoration: const InputDecoration(
                    labelText: 'Type Delete to confirm',
                    hintText: 'Delete',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setDialogState(() => error = null),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: canConfirm
                  ? () async {
                      setDialogState(() {
                        loading = true;
                        error = null;
                      });
                      try {
                        final api = ctx.read<ApiClient>();
                        final auth = ctx.read<AuthProvider>();
                        await api.post(
                          ApiEndpoints.deleteAccount,
                          data: {'confirmation': 'Delete'},
                        );
                        await auth.logout();
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        if (context.mounted) context.go('/login');
                      } catch (e) {
                        setDialogState(() {
                          loading = false;
                          error = ApiClient.friendlyError(e);
                        });
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Delete Account'),
            ),
          ],
        );
      },
    ),
  );

  confirmCtrl.dispose();
}
