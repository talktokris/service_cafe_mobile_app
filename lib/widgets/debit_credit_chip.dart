import 'package:flutter/material.dart';

class DebitCreditChip extends StatelessWidget {
  const DebitCreditChip({super.key, required this.debitCredit, this.compact = false});

  /// 1 = debit, 2 = credit
  final int debitCredit;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDebit = debitCredit == 1;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 10, vertical: compact ? 3 : 4),
      decoration: BoxDecoration(
        color: isDebit ? const Color(0xFFFEECEC) : const Color(0xFFE8F5EE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        compact ? (isDebit ? 'D' : 'C') : (isDebit ? 'Debit' : 'Credit'),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDebit ? Colors.red.shade800 : Colors.green.shade800,
        ),
      ),
    );
  }
}
