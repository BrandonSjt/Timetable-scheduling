import 'package:flutter/material.dart';
import 'core/routing/router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Root widget aplikasi KAI Access Prototype.
/// Menggunakan GoRouter untuk navigasi dan AppTheme untuk tampilan.
/// Tanpa state management (ProviderScope) sesuai permintaan.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KAI Access Prototype',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
