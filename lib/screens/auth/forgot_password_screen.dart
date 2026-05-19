import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;
  String? _message;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_email.text.trim().isEmpty) return;
    setState(() { _loading = true; _error = null; _message = null; });
    try {
      final body = await context.read<ApiClient>().post(ApiEndpoints.forgotPassword, data: {'email': _email.text.trim()});
      setState(() => _message = body['message']?.toString() ?? 'Check your email for the reset code.');
      if (mounted) {
        context.push('/reset-password', extra: _email.text.trim());
      }
    } catch (e) {
      setState(() => _error = ApiClient.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      title: 'Forgot Password',
      subtitle: 'We will email you a 6-digit code to reset your password',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
          ),
          if (_message != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_message!, style: const TextStyle(color: Colors.green))),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: Colors.red))),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _loading ? null : _send, child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Send Reset Code')),
          TextButton(onPressed: () => context.go('/login'), child: const Text('Back to Sign In', style: TextStyle(color: AppColors.primary))),
        ],
      ),
    );
  }
}
