import 'package:flutter/material.dart';
import 'package:timetable/l10n/app_localizations.dart';

Widget localizedTestApp({
  required Widget home,
  Locale locale = const Locale('id'),
  TransitionBuilder? builder,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: builder,
    home: home,
  );
}
