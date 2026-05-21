import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/widgets/auth_scaffold.dart';
import 'package:serve_cafe_mobile/widgets/terms_of_use_modal.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.initialReferralCode});

  final String? initialReferralCode;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _referral = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _referrerName;
  bool _referralValid = false;
  bool _checkingReferral = false;
  bool _loading = false;
  String? _error;
  String? _success;
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialReferralCode != null) {
      _referral.text = widget.initialReferralCode!;
      _validateReferral();
    }
  }

  @override
  void dispose() {
    _referral.dispose();
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _validateReferral() async {
    final code = _referral.text.trim().toLowerCase();
    if (code.length < 3) {
      setState(() { _referralValid = false; _referrerName = null; });
      return;
    }
    setState(() { _checkingReferral = true; _error = null; });
    try {
      final body = await context.read<ApiClient>().get('${ApiEndpoints.validateReferral}/$code');
      final data = body['data'] as Map<String, dynamic>;
      setState(() {
        _referralValid = true;
        _referrerName = data['referrer_name']?.toString();
      });
    } catch (e) {
      setState(() { _referralValid = false; _referrerName = null; _error = 'Invalid referral code'; });
    } finally {
      setState(() => _checkingReferral = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_referralValid) {
      setState(() => _error = 'Please enter a valid referral code');
      return;
    }
    if (!_termsAccepted) {
      setState(() => _error = 'You must accept the Terms of Use to register');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<ApiClient>().post(ApiEndpoints.register, data: {
        'referral_code': _referral.text.trim().toLowerCase(),
        'first_name': _first.text.trim(),
        'last_name': _last.text.trim(),
        'email': _email.text.trim(),
        'password': _password.text,
        'password_confirmation': _confirm.text,
        'terms_accepted': true,
      });
      setState(() => _success = 'Registration successful! You can sign in now.');
      if (mounted) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.go('/login');
        });
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
      title: 'Join Serve Cafe',
      subtitle: _referrerName != null ? 'Referred by $_referrerName' : 'Enter a referral code to register',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _referral,
              decoration: InputDecoration(
                labelText: 'Referral Code *',
                prefixIcon: const Icon(Icons.link),
                suffixIcon: _checkingReferral
                    ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                    : Icon(_referralValid ? Icons.check_circle : Icons.help_outline, color: _referralValid ? Colors.green : null),
                helperText: 'Same code from /join/yourcode link on the website',
              ),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9]'))],
              onChanged: (_) => _validateReferral(),
              validator: (v) => v == null || v.length < 3 ? 'Referral code required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _first, decoration: const InputDecoration(labelText: 'First Name *'), validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _last, decoration: const InputDecoration(labelText: 'Last Name *'), validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email *'), validator: (v) => v!.contains('@') ? null : 'Valid email required'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: _obscure1,
              decoration: InputDecoration(labelText: 'Password *', helperText: 'Min 8 characters', suffixIcon: IconButton(icon: Icon(_obscure1 ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscure1 = !_obscure1))),
              validator: (v) => v!.length < 8 ? 'Min 8 characters' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirm,
              obscureText: _obscure2,
              decoration: InputDecoration(labelText: 'Confirm Password *', suffixIcon: IconButton(icon: Icon(_obscure2 ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscure2 = !_obscure2))),
              validator: (v) => v != _password.text ? 'Passwords must match' : null,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _termsAccepted,
                  activeColor: AppColors.primary,
                  onChanged: _loading
                      ? null
                      : (v) => setState(() {
                            _termsAccepted = v ?? false;
                            if (_termsAccepted) _error = null;
                          }),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _loading ? null : () => showTermsOfUseModal(context),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(fontSize: 14, height: 1.4),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Use',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: Colors.red))),
            if (_success != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_success!, style: const TextStyle(color: Colors.green))),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _loading ? null : _register, child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Register')),
            TextButton(onPressed: () => context.go('/login'), child: const Text('Already have an account? Sign In', style: TextStyle(color: AppColors.primary))),
          ],
        ),
      ),
    );
  }
}
