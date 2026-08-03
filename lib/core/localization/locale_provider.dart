import 'package:flutter/material.dart';

class LocaleScope extends InheritedNotifier<ValueNotifier<Locale>> {
  const LocaleScope({
    super.key,
    required ValueNotifier<Locale> super.notifier,
    required super.child,
  });

  static ValueNotifier<Locale> of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LocaleScope>()!
        .notifier!;
  }
}
