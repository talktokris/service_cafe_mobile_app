import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';

class TransferDialog extends StatefulWidget {
  const TransferDialog({super.key, required this.maxAmount});
  final double maxAmount;

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  final _amount = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    final value = double.tryParse(_amount.text);
    if (value == null || value <= 0 || value > widget.maxAmount) return;
    setState(() => _loading = true);
    try {
      await context.read<ApiClient>().post(ApiEndpoints.cashWalletTransfer, data: {'amount': value});
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiClient.friendlyError(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Transfer to Purchase Wallet'),
      content: TextField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (NRS)')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _loading ? null : _submit, child: const Text('Transfer')),
      ],
    );
  }
}
