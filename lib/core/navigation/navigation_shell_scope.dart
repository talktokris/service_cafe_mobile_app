import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationShellScope extends InheritedWidget {
  const NavigationShellScope({
    super.key,
    required this.navigationShell,
    required super.child,
  });

  final StatefulNavigationShell navigationShell;

  static StatefulNavigationShell of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<NavigationShellScope>();
    assert(scope != null, 'NavigationShellScope not found');
    return scope!.navigationShell;
  }

  @override
  bool updateShouldNotify(NavigationShellScope oldWidget) =>
      navigationShell != oldWidget.navigationShell;
}
