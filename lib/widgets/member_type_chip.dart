import 'package:flutter/material.dart';
class MemberTypeChip extends StatelessWidget {
  const MemberTypeChip({super.key, required this.isPaid});

  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? Colors.amber.shade100 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isPaid ? Colors.amber.shade700 : Colors.blue.shade300),
      ),
      child: Text(
        isPaid ? 'Paid Member' : 'Free Member',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isPaid ? Colors.amber.shade900 : Colors.blue.shade800,
        ),
      ),
    );
  }
}

