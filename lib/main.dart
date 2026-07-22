import 'package:flutter/material.dart';
import 'core/routing/router.dart';
import 'core/theme/app_theme.dart';
import 'features/travel_alarm/presentation/controllers/travel_alarm_controller.dart';
import 'features/travel_alarm/presentation/widgets/travel_alarm_scope.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Root widget aplikasi KAI Access Prototype.
/// Menggunakan GoRouter untuk navigasi dan AppTheme untuk tampilan.
/// Tanpa state management (ProviderScope) sesuai permintaan.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final TravelAlarmController _travelAlarmController;

  @override
  void initState() {
    super.initState();
    _travelAlarmController = TravelAlarmController();
  }

  @override
  void dispose() {
    _travelAlarmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TravelAlarmScope(
      controller: _travelAlarmController,
      child: MaterialApp.router(
        title: 'KAI Access Prototype',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
