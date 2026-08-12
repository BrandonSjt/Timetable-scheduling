import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> readArb(String path) {
  return (jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>);
}

Set<String> messageKeys(Map<String, Object?> arb) => arb.keys
    .where((key) => !key.startsWith('@'))
    .toSet();

Set<String> metadataKeys(Map<String, Object?> arb) => arb.keys
    .where((key) => key.startsWith('@') && key != '@@locale')
    .toSet();

Set<String> placeholders(Object? value) {
  if (value is! String) return const <String>{};
  return RegExp(
    r'\{([A-Za-z][A-Za-z0-9_]*)',
  ).allMatches(value).map((match) => match.group(1)!).toSet();
}

double scriptCoverage(Map<String, Object?> arb, RegExp script) {
  final messages = arb.entries
      .where((entry) => !entry.key.startsWith('@'))
      .map((entry) => entry.value)
      .whereType<String>()
      .where((value) => value.trim().isNotEmpty)
      .toList();
  final translated = messages.where(script.hasMatch).length;
  return translated / messages.length;
}

void main() {
  final english = readArb('lib/l10n/app_en.arb');

  for (final locale in const <String>['id', 'zh', 'zh_Hans', 'ar']) {
    test('$locale catalog has a complete localization contract', () {
      final catalog = readArb('lib/l10n/app_$locale.arb');
      expect(messageKeys(catalog), messageKeys(english));
      expect(metadataKeys(catalog), metadataKeys(english));

      for (final key in messageKeys(english)) {
        expect(
          (catalog[key] as String).trim(),
          isNotEmpty,
          reason: 'Empty translation for $locale.$key',
        );
        expect(
          placeholders(catalog[key]),
          placeholders(english[key]),
          reason: 'Placeholder mismatch for $locale.$key',
        );
      }

      for (final key in metadataKeys(english)) {
        expect(
          catalog[key],
          english[key],
          reason: 'Metadata or placeholder type mismatch for $locale.$key',
        );
      }
    });
  }

  test('Chinese base fallback stays synchronized with zh_Hans', () {
    final chineseBase = readArb('lib/l10n/app_zh.arb')..remove('@@locale');
    final simplifiedChinese = readArb('lib/l10n/app_zh_Hans.arb')
      ..remove('@@locale');
    expect(chineseBase, simplifiedChinese);
  });

  test('Simplified Chinese contains Chinese text instead of bulk fallback', () {
    final chinese = readArb('lib/l10n/app_zh_Hans.arb');
    expect(
      scriptCoverage(chinese, RegExp(r'[\u3400-\u9FFF]')),
      greaterThan(0.80),
    );
  });

  test('Arabic contains Arabic text instead of bulk fallback', () {
    final arabic = readArb('lib/l10n/app_ar.arb');
    expect(
      scriptCoverage(arabic, RegExp(r'[\u0600-\u06FF]')),
      greaterThan(0.80),
    );
  });
}
