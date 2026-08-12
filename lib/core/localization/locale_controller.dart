import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app_locale.dart';
import 'locale_storage.dart';

class LocaleController extends ValueNotifier<AppLocale> {
  LocaleController({
    required AppLocale initialLocale,
    LocaleStorage? storage,
  }) : _storage = storage,
       super(initialLocale);

  final LocaleStorage? _storage;

  static Future<LocaleController> load({
    required LocaleStorage storage,
    required Iterable<Locale> deviceLocales,
  }) async {
    String? savedTag;
    try {
      savedTag = await storage.readLocaleTag();
    } on Object {
      savedTag = null;
    }

    return LocaleController(
      initialLocale: AppLocale.resolve(
        savedTag: savedTag,
        deviceLocales: deviceLocales,
      ),
      storage: storage,
    );
  }

  Future<bool> select(AppLocale locale) async {
    value = locale;
    final storage = _storage;
    if (storage == null) return true;

    try {
      await storage.writeLocaleTag(locale.storageTag);
      return true;
    } on Object {
      return false;
    }
  }
}
