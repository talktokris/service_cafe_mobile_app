import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/data/nepal_banks.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/payout_icon.dart';
import 'package:serve_cafe_mobile/widgets/pull_to_refresh.dart';

class BankEwalletSetupScreen extends StatefulWidget {
  const BankEwalletSetupScreen({super.key});

  @override
  State<BankEwalletSetupScreen> createState() => _BankEwalletSetupScreenState();
}

class _BankEwalletSetupScreenState extends State<BankEwalletSetupScreen> {
  final _holderController = TextEditingController();
  final _accountNoController = TextEditingController();
  final _esewaController = TextEditingController();
  final _khaltiController = TextEditingController();

  String _bankName = '';
  String _accountType = '';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _holderController.dispose();
    _accountNoController.dispose();
    _esewaController.dispose();
    _khaltiController.dispose();
    super.dispose();
  }

  String? get _bankDropdownValue {
    if (_bankName.isEmpty) return null;
    return kNepalBanks.contains(_bankName) ? _bankName : null;
  }

  String? get _accountTypeDropdownValue {
    if (_accountType.isEmpty) return null;
    const allowed = {'saving', 'current'};
    return allowed.contains(_accountType) ? _accountType : null;
  }

  Future<void> _load() async {
    try {
      final body = await context.read<ApiClient>().get(
        ApiEndpoints.profileBankEwallet,
      );
      final data = body['data'] as Map<String, dynamic>? ?? {};

      if (!mounted) return;
      setState(() {
        _bankName = ((data['bank_account_name'] as String?) ?? '').trim();
        _accountType = ((data['account_type'] as String?) ?? '').trim();
        _holderController.text =
            (data['account_holder_name'] as String?) ?? '';
        _accountNoController.text = (data['account_number'] as String?) ?? '';
        _esewaController.text = (data['esewa_wallet'] as String?) ?? '';
        _khaltiController.text = (data['khalti_wallet'] as String?) ?? '';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ApiClient.friendlyError(e))));
      setState(() => _loading = false);
    }
  }

  String? _optionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await context.read<ApiClient>().put(
        ApiEndpoints.profileBankEwallet,
        data: {
          'bank_account_name': _optionalText(_bankName),
          'account_type': _optionalText(_accountType),
          'account_holder_name': _optionalText(_holderController.text),
          'account_number': _optionalText(_accountNoController.text),
          'esewa_wallet': _optionalText(_esewaController.text),
          'khalti_wallet': _optionalText(_khaltiController.text),
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bank & eWallet setup saved'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ApiClient.friendlyError(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _sectionTitle(String title, {required String iconAsset}) {
    return Row(
      children: [
        PayoutIcon(asset: iconAsset, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: 'Bank & eWallet Setup',
        showBack: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : PullToRefresh.list(
              onRefresh: _load,
              padding: const EdgeInsets.all(16),
              children: [
                _card(
                  title: _sectionTitle(
                    'Bank Account Setup',
                    iconAsset: PayoutAssets.bank,
                  ),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        key: ValueKey('bank_$_bankName'),
                        initialValue: _bankDropdownValue,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Bank Account Name',
                          prefixIcon: payoutPrefixIcon(PayoutAssets.bank),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Select bank (optional)'),
                          ),
                          ...kNepalBanks.map(
                            (bank) => DropdownMenuItem(
                              value: bank,
                              child: Text(bank),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _bankName = value ?? ''),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        key: ValueKey('acct_$_accountType'),
                        initialValue: _accountTypeDropdownValue,
                        decoration: const InputDecoration(
                          labelText: 'Account Type',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('Select account type (optional)'),
                          ),
                          DropdownMenuItem(
                            value: 'saving',
                            child: Text('Saving Account'),
                          ),
                          DropdownMenuItem(
                            value: 'current',
                            child: Text('Current Account'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _accountType = value ?? ''),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _holderController,
                        decoration: const InputDecoration(
                          labelText: 'Account Holder Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _accountNoController,
                        decoration: const InputDecoration(
                          labelText: 'Account Number',
                          prefixIcon: Icon(Icons.confirmation_number_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
                _card(
                  title: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 22,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'eWallet Setup',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _esewaController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'eSewa Wallet',
                          hintText: 'eSewa number or ID',
                          prefixIcon: payoutPrefixIcon(PayoutAssets.esewa),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _khaltiController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Khalti Wallet',
                          hintText: 'Khalti number or ID',
                          prefixIcon: payoutPrefixIcon(PayoutAssets.khalti),
                        ),
                      ),
                    ],
                  ),
                ),
                _card(
                  title: const Text(
                    'Note',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  child: const Text(
                    'All fields are optional. You can save only bank details, only wallet details, or both.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Setup'),
                  ),
                ),
              ],
            ),
    );
  }
}
