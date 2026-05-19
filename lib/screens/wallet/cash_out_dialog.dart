import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';

class CashOutDialog extends StatefulWidget {
  const CashOutDialog({super.key, required this.maxAmount});
  final double maxAmount;

  @override
  State<CashOutDialog> createState() => _CashOutDialogState();
}

class _CashOutDialogState extends State<CashOutDialog> {
  final _amount = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = double.tryParse(_amount.text);
    if (value == null || value <= 0 || value > widget.maxAmount) {
      setState(() => _error = 'Invalid amount');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<ApiClient>().post(ApiEndpoints.cashWalletCashOut, data: {'amount': value});
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = ApiClient.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cash Out'),
      content: TextField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (NRS)')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _loading ? null : _submit, child: const Text('Submit')),
      ],
    );
  }
}
