import 'package:timetable/core/localization/locale_storage.dart';

class FakeLocaleStorage implements LocaleStorage {
  String? value;
  Object? readError;
  Object? writeError;

  @override
  Future<String?> readLocaleTag() async {
    if (readError case final error?) throw error;
    return value;
  }

  @override
  Future<void> writeLocaleTag(String tag) async {
    if (writeError case final error?) throw error;
    value = tag;
  }
}
