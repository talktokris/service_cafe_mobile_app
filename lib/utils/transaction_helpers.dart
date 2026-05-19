import 'package:flutter/material.dart';

String earningTypeLabel(int? type) {
  switch (type) {
    case 1:
      return 'Earning';
    case 2:
      return 'Withdrawal';
    case 3:
      return 'Redistribution';
    default:
      return 'Unknown';
  }
}

Color earningTypeColor(int? type) {
  switch (type) {
    case 1:
      return Colors.green.shade800;
    case 2:
      return Colors.red.shade800;
    case 3:
      return Colors.blue.shade800;
    default:
      return Colors.grey.shade800;
  }
}

Color earningTypeBg(int? type) {
  switch (type) {
    case 1:
      return Colors.green.shade50;
    case 2:
      return Colors.red.shade50;
    case 3:
      return Colors.blue.shade50;
    default:
      return Colors.grey.shade100;
  }
}

String cashWalletTypeLabel(int? type) {
  switch (type) {
    case 1:
      return 'Cash In';
    case 2:
      return 'Tax';
    case 3:
      return 'Withdrawal';
    case 4:
      return 'Transfer';
    default:
      return 'Unknown';
  }
}

Color cashWalletTypeColor(int? type) {
  switch (type) {
    case 1:
      return Colors.green.shade800;
    case 2:
      return Colors.red.shade800;
    case 3:
      return Colors.orange.shade800;
    case 4:
      return Colors.blue.shade800;
    default:
      return Colors.grey.shade800;
  }
}

Color cashWalletTypeBg(int? type) {
  switch (type) {
    case 1:
      return Colors.green.shade50;
    case 2:
      return Colors.red.shade50;
    case 3:
      return Colors.orange.shade50;
    case 4:
      return Colors.blue.shade50;
    default:
      return Colors.grey.shade100;
  }
}

Color debitCreditAmountColor(int debitCredit) =>
    debitCredit == 1 ? Colors.red.shade700 : Colors.green.shade700;

Color paymentTypeColor(String? type) {
  switch (type?.toLowerCase()) {
    case 'cash':
      return Colors.green.shade800;
    case 'online':
      return Colors.blue.shade800;
    case 'wallet':
      return Colors.purple.shade800;
    case 'card':
      return Colors.indigo.shade800;
    default:
      return Colors.grey.shade800;
  }
}

Color paymentTypeBg(String? type) {
  switch (type?.toLowerCase()) {
    case 'cash':
      return Colors.green.shade50;
    case 'online':
      return Colors.blue.shade50;
    case 'wallet':
      return Colors.purple.shade50;
    case 'card':
      return Colors.indigo.shade50;
    default:
      return Colors.grey.shade100;
  }
}

/// Running balance for newest-first ledger (same as web).
List<Map<String, dynamic>> withRunningBalances(
  List<dynamic> items,
  double totalBalance,
) {
  if (items.isEmpty) return [];

  final sorted = [...items]
    ..sort((a, b) => ((b as Map)['id'] as num).compareTo((a as Map)['id'] as num));

  var balance = totalBalance;
  final result = <Map<String, dynamic>>[];

  for (var i = 0; i < sorted.length; i++) {
    final tx = Map<String, dynamic>.from(sorted[i] as Map<String, dynamic>);
    if (i == 0) {
      tx['calculated_balance'] = balance;
    } else {
      final amount = (tx['amount'] as num?)?.toDouble() ?? 0;
      final dc = (tx['debit_credit'] as num?)?.toInt() ?? 0;
      if (dc == 1) {
        balance += amount;
      } else {
        balance -= amount;
      }
      tx['calculated_balance'] = balance;
    }
    result.add(tx);
  }
  return result;
}

String orderLocation(Map<String, dynamic> order) {
  final branch = order['branch'] as Map<String, dynamic>?;
  final head = order['head_office'] as Map<String, dynamic>? ?? order['headOffice'] as Map<String, dynamic>?;
  if (branch != null) {
    return branch['office_name']?.toString() ??
        branch['name']?.toString() ??
        branch['companyName']?.toString() ??
        'Unknown Location';
  }
  if (head != null) {
    return head['office_name']?.toString() ??
        head['companyName']?.toString() ??
        head['name']?.toString() ??
        'Unknown Location';
  }
  return 'Unknown Location';
}

String orderCashier(Map<String, dynamic> order) {
  final creator = order['creator'] as Map<String, dynamic>?;
  if (creator == null) return 'Unknown Cashier';
  final first = creator['first_name']?.toString() ?? '';
  final last = creator['last_name']?.toString() ?? '';
  final full = '$first $last'.trim();
  if (full.isNotEmpty) return full;
  return creator['name']?.toString() ?? 'Unknown Cashier';
}

DateTime monthStart(DateTime now) => DateTime(now.year, now.month, 1);

DateTime monthEnd(DateTime now) => DateTime(now.year, now.month + 1, 0);

/// Default history window: 12 months through today (shows records outside current month).
DateTime defaultHistoryFrom(DateTime now) {
  final d = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 365));
  return DateTime(d.year, d.month, d.day);
}

DateTime defaultHistoryTo(DateTime now) => DateTime(now.year, now.month, now.day);

String initialsFromName(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
