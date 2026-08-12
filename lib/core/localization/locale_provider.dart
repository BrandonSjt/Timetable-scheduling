import 'package:flutter/material.dart';

import 'locale_controller.dart';

class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    super.key,
    required LocaleController super.notifier,
    required super.child,
  });

  static LocaleController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleScope>()!.notifier!;
  }
}
