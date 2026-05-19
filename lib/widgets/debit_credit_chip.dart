import 'package:flutter/material.dart';

class DebitCreditChip extends StatelessWidget {
  const DebitCreditChip({super.key, required this.debitCredit});

  /// 1 = debit, 2 = credit
  final int debitCredit;

  @override
  Widget build(BuildContext context) {
    final isDebit = debitCredit == 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDebit ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isDebit ? Colors.red.shade200 : Colors.green.shade200),
      ),
      child: Text(
        isDebit ? 'Debit' : 'Credit',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDebit ? Colors.red.shade800 : Colors.green.shade800,
        ),
      ),
    );
  }
}
