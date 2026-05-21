import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/utils/format.dart';
import 'package:serve_cafe_mobile/utils/transaction_helpers.dart';
import 'package:serve_cafe_mobile/widgets/empty_state.dart';
import 'package:serve_cafe_mobile/widgets/error_state.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/loading_overlay.dart';
import 'package:serve_cafe_mobile/widgets/premium_list_card.dart';

class MyOrderOtpScreen extends StatefulWidget {
  const MyOrderOtpScreen({super.key});

  @override
  State<MyOrderOtpScreen> createState() => _MyOrderOtpScreenState();
}

class _MyOrderOtpScreenState extends State<MyOrderOtpScreen> {
  List<dynamic> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final body = await context.read<ApiClient>().get(ApiEndpoints.orderOtps);
      final list = body['data'] as List<dynamic>? ?? [];
      if (mounted) setState(() => _orders = list);
    } catch (e) {
      if (mounted) setState(() => _error = ApiClient.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _otpFor(Map<String, dynamic> o) {
    final txn = o['txn_otp']?.toString().trim();
    if (txn != null && txn.isNotEmpty) return txn;
    final code = o['otp_code']?.toString().trim();
    if (code != null && code.isNotEmpty) return code;
    return '—';
  }

  String _paymentLabel(dynamic status) {
    final s = status?.toString();
    if (s == '0' || s == 'unpaid') return 'Unpaid';
    if (s == '1' || s == 'paid') return 'Paid';
    return s ?? '—';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'My Order OTP', showBack: true),
      body: _loading
          ? const LoadingOverlay()
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : _orders.isEmpty
                  ? const EmptyState(
                      message: 'No orders found.',
                      icon: Icons.pin_outlined,
                    )
                  : RefreshIndicator(
                      color: AppColors.accent,
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final o = _orders[index] as Map<String, dynamic>;
                          final otp = _otpFor(o);
                          final hasOtp = otp != '—';
                          final id = o['id'];

                          return PremiumListCard(
                            onTap: id != null ? () => context.push('/orders/$id') : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        o['orderShortName']?.toString() ?? 'Order #$id',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _paymentLabel(o['paymentStatus']) == 'Paid'
                                            ? AppColors.successSoft
                                            : AppColors.warningSoft,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _paymentLabel(o['paymentStatus']),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _paymentLabel(o['paymentStatus']) == 'Paid'
                                              ? AppColors.success
                                              : AppColors.warning,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  formatDateTime(o['created_at']?.toString()),
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                                Text(
                                  'Location: ${orderLocation(o)}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                if (o['item_count'] != null)
                                  Text(
                                    'Items: ${o['item_count']}',
                                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                                  ),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: hasOtp
                                        ? AppColors.infoSoft
                                        : AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: hasOtp
                                          ? AppColors.info.withValues(alpha: 0.3)
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.lock_outline,
                                        size: 22,
                                        color: hasOtp ? AppColors.info : AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'OTP',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textMuted,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              otp,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: hasOtp ? 2 : 0,
                                                fontFamily: hasOtp ? 'monospace' : null,
                                                color: hasOtp
                                                    ? AppColors.primary
                                                    : AppColors.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (hasOtp)
                                        IconButton(
                                          tooltip: 'Copy OTP',
                                          icon: const Icon(Icons.copy_outlined, size: 20),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(text: otp));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('OTP copied')),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    formatNrs(o['sellingPrice'] ?? 0),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
