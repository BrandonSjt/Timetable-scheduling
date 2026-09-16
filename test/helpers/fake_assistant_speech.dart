import 'dart:async';

import 'package:timetable/features/assistant/data/services/assistant_speech_recognizer.dart';
import 'package:timetable/features/route_result/domain/services/route_speech_service.dart';

class FakeAssistantSpeechRecognizer implements AssistantSpeechRecognizer {
  bool available = true;
  Completer<bool>? initialization;
  int listenCalls = 0;
  int cancelCalls = 0;
  String? languageCode;
  void Function(String, bool)? resultListener;
  void Function(String)? errorListener;
  void Function(String)? statusListener;

  @override
  Future<bool> initialize({
    required void Function(String) onError,
    required void Function(String) onStatus,
  }) async {
    errorListener = onError;
    statusListener = onStatus;
    return initialization == null ? available : initialization!.future;
  }

  @override
  Future<void> listen({
    required String languageCode,
    required void Function(String, bool) onResult,
  }) async {
    listenCalls++;
    this.languageCode = languageCode;
    resultListener = onResult;
  }

  void emit(String text, {bool isFinal = false}) =>
      resultListener?.call(text, isFinal);

  @override
  Future<void> stop() async {}

  @override
  Future<void> cancel() async {
    cancelCalls++;
  }
}

class FakeAssistantPlayback implements RouteSpeechService {
  String? spokenText;
  String? languageCode;
  int stopCalls = 0;
  Completer<void>? completion;

  @override
  Future<void> speak(String text, String languageCode) async {
    spokenText = text;
    this.languageCode = languageCode;
    if (completion != null) await completion!.future;
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async {
    stopCalls++;
  }
}
