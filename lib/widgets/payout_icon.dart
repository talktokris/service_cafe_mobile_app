import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Payout brand SVGs (same assets as web `/images/payout/*.svg`).
abstract final class PayoutAssets {
  static const bank = 'assets/images/payout/bank.svg';
  static const esewa = 'assets/images/payout/esewa.svg';
  static const khalti = 'assets/images/payout/khalti.svg';
}

class PayoutIcon extends StatelessWidget {
  const PayoutIcon({
    super.key,
    required this.asset,
    this.size = 24,
  });

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(asset, width: size, height: size);
  }
}

/// Sized for [InputDecoration.prefixIcon].
Widget payoutPrefixIcon(String asset, {double size = 22}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    child: PayoutIcon(asset: asset, size: size),
  );
}
