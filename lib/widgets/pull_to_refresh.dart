import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

/// Lets [RefreshIndicator] work even when content is shorter than the viewport.
const refreshScrollPhysics = AlwaysScrollableScrollPhysics(
  parent: BouncingScrollPhysics(),
);

/// Pull down to reload screen data (same gesture as mobile web refresh).
class PullToRefresh extends StatelessWidget {
  const PullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: onRefresh,
      child: child,
    );
  }

  factory PullToRefresh.list({
    Key? key,
    required Future<void> Function() onRefresh,
    required List<Widget> children,
    EdgeInsetsGeometry? padding,
    ScrollController? controller,
  }) {
    return PullToRefresh(
      key: key,
      onRefresh: onRefresh,
      child: ListView(
        controller: controller,
        padding: padding,
        physics: refreshScrollPhysics,
        children: children,
      ),
    );
  }

  factory PullToRefresh.builder({
    Key? key,
    required Future<void> Function() onRefresh,
    required NullableIndexedWidgetBuilder itemBuilder,
    required int itemCount,
    EdgeInsetsGeometry? padding,
    ScrollController? controller,
  }) {
    return PullToRefresh(
      key: key,
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: controller,
        padding: padding,
        physics: refreshScrollPhysics,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }

  /// Use when the body is not already a scroll view (e.g. short forms).
  factory PullToRefresh.wrap({
    Key? key,
    required Future<void> Function() onRefresh,
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return PullToRefresh(
      key: key,
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: refreshScrollPhysics,
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
