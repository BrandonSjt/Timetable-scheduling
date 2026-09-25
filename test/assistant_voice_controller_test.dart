import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/assistant/presentation/controllers/assistant_controller.dart';

import 'helpers/fake_assistant_speech.dart';

void main() {
  testWidgets(
    'late final after done is accepted once within platform timeout',
    (tester) async {
      final recognizer = FakeAssistantSpeechRecognizer();
      final requests = <String>[];
      final controller = AssistantController(
        recognizer: recognizer,
        speechService: FakeAssistantPlayback(),
        onTranscript: (text) async {
          requests.add(text);
          return 'Balasan backend';
        },
      );
      addTearDown(controller.dispose);
      await controller.startConversation();
      recognizer.statusListener!('done');
      await tester.pump(const Duration(seconds: 2));
      recognizer.emit('Dari Bekasi', isFinal: true);
      await tester.pump();
      expect(requests, ['Dari Bekasi']);
      expect(controller.assistantResponse, 'Balasan backend');
      await tester.pump(const Duration(seconds: 1));
      expect(controller.state, AssistantInteractionState.confirmation);
    },
  );

  test(
    'partial sends nothing; one final sends once and exposes real reply',
    () async {
      final recognizer = FakeAssistantSpeechRecognizer();
      final reply = Completer<String?>();
      final requests = <String>[];
      final controller = AssistantController(
        recognizer: recognizer,
        speechService: FakeAssistantPlayback(),
        onTranscript: (text) {
          requests.add(text);
          return reply.future;
        },
      );
      addTearDown(controller.dispose);

      await controller.startConversation();
      recognizer.emit('Aku mau ke');
      expect(controller.userTranscript, 'Aku mau ke');
      expect(requests, isEmpty);
      recognizer.emit('Aku mau ke Jakarta Kota dari Bintaro', isFinal: true);
      recognizer.emit('Aku mau ke Jakarta Kota dari Bintaro', isFinal: true);
      expect(requests, ['Aku mau ke Jakarta Kota dari Bintaro']);
      expect(controller.state, AssistantInteractionState.processing);
      reply.complete('Bintaro dekat Pondok Ranji. Kamu berangkat dari sana?');
      await Future<void>.delayed(Duration.zero);
      expect(controller.assistantResponse, contains('Pondok Ranji'));
      expect(controller.state, AssistantInteractionState.confirmation);
      expect(controller.completedExchangeId, 1);
    },
  );

  test('empty final and no-match never send a request', () async {
    final recognizer = FakeAssistantSpeechRecognizer();
    var calls = 0;
    final controller = AssistantController(
      recognizer: recognizer,
      speechService: FakeAssistantPlayback(),
      onTranscript: (_) async {
        calls++;
        return 'reply';
      },
    );
    addTearDown(controller.dispose);
    await controller.startConversation();
    recognizer.emit(' ', isFinal: true);
    expect(controller.state, AssistantInteractionState.ready);
    await controller.startConversation();
    recognizer.errorListener!('error_no_match');
    expect(controller.state, AssistantInteractionState.ready);
    expect(calls, 0);
  });

  test(
    'permission denied and unavailable recognition show error without demo',
    () async {
      final recognizer = FakeAssistantSpeechRecognizer()..available = false;
      final controller = AssistantController(
        recognizer: recognizer,
        speechService: FakeAssistantPlayback(),
      );
      addTearDown(controller.dispose);
      await controller.startConversation();
      expect(controller.state, AssistantInteractionState.error);
      expect(controller.errorCode, 'VOICE_UNAVAILABLE');
      expect(controller.userTranscript, isNull);
      recognizer.available = true;
      await controller.startConversation();
      recognizer.errorListener!('error_permission');
      expect(controller.errorCode, 'error_permission');
      expect(controller.assistantResponse, isNull);
    },
  );

  test('cancel and dispose ignore late final callbacks', () async {
    final recognizer = FakeAssistantSpeechRecognizer();
    var calls = 0;
    final controller = AssistantController(
      recognizer: recognizer,
      speechService: FakeAssistantPlayback(),
      onTranscript: (_) async {
        calls++;
        return 'reply';
      },
    );
    await controller.startConversation();
    controller.cancelConversation();
    recognizer.emit('late result', isFinal: true);
    expect(calls, 0);
    await controller.startConversation();
    controller.dispose();
    recognizer.emit('late result', isFinal: true);
    expect(calls, 0);
  });

  test(
    'cancel during initialization prevents microphone from starting',
    () async {
      final recognizer = FakeAssistantSpeechRecognizer()
        ..initialization = Completer<bool>();
      final controller = AssistantController(
        recognizer: recognizer,
        speechService: FakeAssistantPlayback(),
      );
      addTearDown(controller.dispose);
      final start = controller.startConversation();
      await Future<void>.delayed(Duration.zero);
      controller.cancelConversation();
      recognizer.initialization!.complete(true);
      await start;
      expect(recognizer.listenCalls, 0);
      expect(controller.state, AssistantInteractionState.ready);
    },
  );

  test(
    'read and stop use actual TTS without another backend request',
    () async {
      final playback = FakeAssistantPlayback()..completion = Completer<void>();
      final controller = AssistantController(
        recognizer: FakeAssistantSpeechRecognizer(),
        speechService: playback,
      );
      addTearDown(controller.dispose);
      controller.languageCode = 'en';
      controller.setResponse('Your route is ready.');
      final read = controller.repeatResponse();
      expect(controller.state, AssistantInteractionState.speaking);
      expect(playback.spokenText, 'Your route is ready.');
      expect(playback.languageCode, 'en');
      controller.stopSpeaking();
      playback.completion!.complete();
      await read;
      expect(controller.state, AssistantInteractionState.confirmation);
      expect(controller.completedExchangeId, 0);
    },
  );
}
