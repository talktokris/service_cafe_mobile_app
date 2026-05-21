import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/auth/auth_provider.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';

class ChangeReferralScreen extends StatefulWidget {
  const ChangeReferralScreen({super.key});

  @override
  State<ChangeReferralScreen> createState() => _ChangeReferralScreenState();
}

class _ChangeReferralScreenState extends State<ChangeReferralScreen> {
  late final TextEditingController _code;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _code = TextEditingController(text: context.read<AuthProvider>().user?.referralCode);
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final code = _code.text.trim().toLowerCase();
    if (code.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Referral code must be at least 3 characters')));
      return;
    }
    final api = context.read<ApiClient>();
    final auth = context.read<AuthProvider>();
    setState(() => _loading = true);
    try {
      await api.put(ApiEndpoints.profileReferral, data: {'referral_code': code});
      await auth.fetchMe();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Referral address updated'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiClient.friendlyError(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final len = _code.text.length;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Change Referral', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: const Icon(Icons.person, color: AppColors.primary)),
              title: Text(user?.name ?? ''),
              subtitle: Text('Current: ${user?.referralCode ?? '—'}'),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _code,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9]'))],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'New Referral Address',
              helperText: '$len / 60 characters (lowercase letters and numbers only)',
              prefixIcon: const Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Important: Changing your referral address affects your share links. Anyone using your old link may need the new address.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading || len < 3 ? null : _save,
            child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Update Referral Address'),
          ),
        ],
      ),
    );
  }
}
