import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/route_result/data/services/native_route_speech_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(NativeRouteSpeechService.channelName);
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('speak sends narration locale and rate to native Android', () async {
    const service = NativeRouteSpeechService();

    await service.speak('Naik dari Bogor', 'id');

    expect(calls.single.method, 'speak');
    expect(calls.single.arguments, {
      'text': 'Naik dari Bogor',
      'locale': 'id-ID',
      'rate': 0.45,
    });
  });

  test(
    'English locale and transport controls keep a stable contract',
    () async {
      const service = NativeRouteSpeechService();

      await service.speak('Route from Bogor', 'en');
      await service.pause();
      await service.stop();

      expect(calls[0].arguments, {
        'text': 'Route from Bogor',
        'locale': 'en-US',
        'rate': 0.45,
      });
      expect(calls[1].method, 'pause');
      expect(calls[2].method, 'stop');
    },
  );
}
