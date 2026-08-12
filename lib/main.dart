import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/localization/app_locale.dart';
import 'core/localization/locale_controller.dart';
import 'core/localization/locale_provider.dart';
import 'core/localization/locale_storage.dart';
import 'core/routing/router.dart';
import 'core/theme/app_theme.dart';
import 'features/travel_alarm/presentation/controllers/travel_alarm_controller.dart';
import 'features/travel_alarm/presentation/widgets/travel_alarm_scope.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeController = await LocaleController.load(
    storage: SharedPreferencesLocaleStorage(SharedPreferencesAsync()),
    deviceLocales: WidgetsBinding.instance.platformDispatcher.locales,
  );
  runApp(MyApp(localeController: localeController));
}

/// Root widget aplikasi KAI Access Prototype.
/// Menggunakan GoRouter untuk navigasi dan AppTheme untuk tampilan.
/// Tanpa state management (ProviderScope) sesuai permintaan.
class MyApp extends StatefulWidget {
  const MyApp({super.key, this.localeController});

  final LocaleController? localeController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final TravelAlarmController _travelAlarmController;
  late final LocaleController _localeController;
  late final bool _ownsLocaleController;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _ownsLocaleController = widget.localeController == null;
    _localeController =
        widget.localeController ??
        LocaleController(initialLocale: AppLocale.indonesian);
    _travelAlarmController = TravelAlarmController();
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

  @override
  void dispose() {
    _travelAlarmController.reminder.removeListener(_handleTravelReminder);
    _travelAlarmController.dispose();
    if (_ownsLocaleController) {
      _localeController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      notifier: _localeController,
      child: TravelAlarmScope(
        controller: _travelAlarmController,
        child: ValueListenableBuilder<AppLocale>(
          valueListenable: _localeController,
          builder: (context, appLocale, child) {
            return MaterialApp.router(
              scaffoldMessengerKey: _scaffoldMessengerKey,
              title: 'KAI Access Prototype',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              routerConfig: appRouter,
              locale: appLocale.locale,
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
    );
  }
}
