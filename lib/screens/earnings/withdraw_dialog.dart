import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';

class WithdrawDialog extends StatefulWidget {
  const WithdrawDialog({super.key, required this.maxAmount, required this.minAmount});

  final double maxAmount;
  final double minAmount;

  @override
  State<WithdrawDialog> createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends State<WithdrawDialog> {
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
    if (value == null || value < widget.minAmount) {
      setState(() => _error = 'Minimum is NRS ${widget.minAmount}');
      return;
    }
    if (value > widget.maxAmount) {
      setState(() => _error = 'Exceeds balance');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<ApiClient>().post(ApiEndpoints.earningsWithdraw, data: {'amount': value});
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
      title: const Text('Withdraw Earnings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (NRS)')),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _loading ? null : _submit, child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Withdraw')),
      ],
    );
  }
}
