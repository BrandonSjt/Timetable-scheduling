import 'package:flutter/material.dart';
import 'core/routing/router.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'features/travel_alarm/presentation/controllers/travel_alarm_controller.dart';
import 'features/travel_alarm/presentation/widgets/travel_alarm_scope.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/widgets/auth_scope.dart';

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
  late final AuthController _authController;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey();
  final ValueNotifier<Locale> _localeNotifier = ValueNotifier(
    const Locale('id'),
  );

  @override
  void initState() {
    super.initState();
    _travelAlarmController = TravelAlarmController();
    _authController = AuthController(AuthRepositoryImpl())
      ..addListener(_handleAuthChange)
      ..bootstrap();
    _travelAlarmController.reminder.addListener(_handleTravelReminder);
  }

  void _handleTravelReminder() {
    final reminder = _travelAlarmController.reminder.value;
    if (reminder == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = _scaffoldMessengerKey.currentState;
      if (messenger == null) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(reminder.message)));
    });
  }

  void _handleAuthChange() {
    final language = _authController.user?.language;
    if (language != null && _localeNotifier.value.languageCode != language) {
      _localeNotifier.value = Locale(language);
    }
  }

  @override
  void dispose() {
    _travelAlarmController.reminder.removeListener(_handleTravelReminder);
    _travelAlarmController.dispose();
    _authController.removeListener(_handleAuthChange);
    _authController.dispose();
    _localeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      notifier: _localeNotifier,
      child: AuthScope(
        controller: _authController,
        child: TravelAlarmScope(
          controller: _travelAlarmController,
          child: ValueListenableBuilder<Locale>(
            valueListenable: _localeNotifier,
            builder: (context, locale, child) {
              return MaterialApp.router(
                scaffoldMessengerKey: _scaffoldMessengerKey,
                title: 'KAI Access Prototype',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                routerConfig: appRouter,
                locale: locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
              );
            },
          ),
        ),
      ),
    );
  }
}
