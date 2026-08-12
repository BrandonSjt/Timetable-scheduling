import 'package:flutter/material.dart';
import 'package:timetable/l10n/app_localizations.dart';

Widget localizedTestApp({required Widget home, TransitionBuilder? builder}) {
  return MaterialApp(
    locale: const Locale('id'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: builder,
    home: home,
  );
}
