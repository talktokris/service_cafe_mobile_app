import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/widgets/auth_scaffold.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) _email.text = widget.initialEmail!;
  }

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (_email.text.isEmpty || _code.text.length != 6 || _password.text.length < 8) {
      setState(() => _error = 'Fill all fields. Code must be 6 digits.');
      return;
    }
    if (_password.text != _confirm.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<ApiClient>().post(ApiEndpoints.resetPassword, data: {
        'email': _email.text.trim(),
        'code': _code.text.trim(),
        'password': _password.text,
        'password_confirmation': _confirm.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset successfully'), backgroundColor: Colors.green));
        context.go('/login');
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
      title: 'Reset Password',
      subtitle: 'Enter the 6-digit code from your email',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
          const SizedBox(height: 12),
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Reset Code',
              prefixIcon: Icon(Icons.pin_outlined),
              counterText: '',
              hintText: '000000',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: _obscure1,
            decoration: InputDecoration(labelText: 'New Password', suffixIcon: IconButton(icon: Icon(_obscure1 ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscure1 = !_obscure1))),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirm,
            obscureText: _obscure2,
            decoration: InputDecoration(labelText: 'Confirm Password', suffixIcon: IconButton(icon: Icon(_obscure2 ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscure2 = !_obscure2))),
          ),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: Colors.red))),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _loading ? null : _reset, child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Reset Password')),
          TextButton(onPressed: () => context.push('/forgot-password'), child: const Text('Resend code', style: TextStyle(color: AppColors.accent))),
          TextButton(onPressed: () => context.go('/login'), child: const Text('Back to Sign In', style: TextStyle(color: AppColors.primary))),
        ],
      ),
    );
  }
}
