import 'package:flutter/material.dart';
import 'package:timetable/l10n/app_localizations.dart';

class LocalizedTestApp extends StatelessWidget {
  const LocalizedTestApp({
    super.key,
    required this.home,
    this.locale,
    this.builder,
  });

  final Widget home;
  final Locale? locale;
  final TransitionBuilder? builder;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale ?? const Locale('id'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: builder,
      home: home,
    );
  }
}
