import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/auth/auth_provider.dart';
import 'package:serve_cafe_mobile/core/auth/token_storage.dart';
import 'package:serve_cafe_mobile/core/router/app_router.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppTheme.setStatusBar();
  runApp(const ServeCafeApp());
}

class ServeCafeApp extends StatefulWidget {
  const ServeCafeApp({super.key});

  @override
  State<ServeCafeApp> createState() => _ServeCafeAppState();
}

class _ServeCafeAppState extends State<ServeCafeApp> {
  late final TokenStorage _tokenStorage;
  late final AuthProvider _authProvider;
  late final ApiClient _apiClient;
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorage();
    _apiClient = ApiClient(_tokenStorage);
    _authProvider = AuthProvider(_apiClient, _tokenStorage);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        Provider<ApiClient>.value(value: _apiClient),
        Provider<TokenStorage>.value(value: _tokenStorage),
      ],
      child: Builder(
        builder: (context) {
          _router ??= AppRouter.create(context);
          return MaterialApp.router(
            title: 'Serve Cafe',
            theme: AppTheme.light(),
            routerConfig: _router!,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
