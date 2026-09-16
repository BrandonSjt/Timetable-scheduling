import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../route_result/data/services/native_route_speech_service.dart';
import '../../../route_result/domain/services/route_speech_service.dart';
import '../../data/services/assistant_speech_recognizer.dart';
import '../../domain/repositories/assistant_chat_repository.dart';
import '../models/assistant_copy.dart';

enum AssistantInteractionState {
  ready,
  listening,
  processing,
  speaking,
  confirmation,
  error,
}

class AssistantController extends ChangeNotifier {
  AssistantController({
    AssistantSpeechRecognizer? recognizer,
    RouteSpeechService? speechService,
    this.onTranscript,
    AssistantCopy? copy,
  }) : _recognizer = recognizer ?? DeviceAssistantSpeechRecognizer.instance,
       _speechService = speechService ?? const NativeRouteSpeechService(),
       _copy = copy ?? AssistantCopy.indonesian();

  final AssistantSpeechRecognizer _recognizer;
  final RouteSpeechService _speechService;
  Future<String?> Function(String)? onTranscript;
  String languageCode = 'id';

  AssistantInteractionState state = AssistantInteractionState.ready;
  bool wakeWordEnabled = false;
  int completedExchangeId = 0;
  String? userTranscript;
  String? assistantResponse;
  String? errorCode;
  AssistantCopy _copy;

  Timer? _completionTimer;
  int _session = 0;
  int _playback = 0;
  bool _disposed = false;
  bool _recognitionStarted = false;

  void configure(AssistantCopy copy) => _copy = copy;

  AssistantCopy get copy => _copy;

  void toggleWakeWord(bool value) {
    // Always-on wake word is not provided by device short-phrase recognition.
    wakeWordEnabled = false;
  }

  Future<void> startConversation() async {
    if (_disposed ||
        state == AssistantInteractionState.listening ||
        state == AssistantInteractionState.processing) {
      return;
    }
    final session = ++_session;
    _playback++;
    _completionTimer?.cancel();
    _recognitionStarted = false;
    userTranscript = null;
    errorCode = null;
    _setState(AssistantInteractionState.listening);
    await _ignoreFailure(_speechService.stop);
    await _ignoreFailure(_recognizer.cancel);
    if (!_current(session)) return;
    try {
      final available = await _recognizer.initialize(
        onError: (code) => _handleRecognitionError(session, code),
        onStatus: (status) => _handleStatus(session, status),
      );
      if (!_current(session) || state != AssistantInteractionState.listening) {
        return;
      }
      if (!available) {
        showError('VOICE_UNAVAILABLE');
        return;
      }
      _recognitionStarted = true;
      await _recognizer.listen(
        languageCode: languageCode,
        onResult: (text, isFinal) => _handleResult(session, text, isFinal),
      );
      // Initialization/listen itself must not reactivate a cancelled session.
      if (!_current(session)) await _ignoreFailure(_recognizer.cancel);
    } on AssistantSpeechRecognitionException catch (error) {
      if (_current(session) && state == AssistantInteractionState.listening) {
        showError(error.code);
      }
    } on Exception {
      if (_current(session) && state == AssistantInteractionState.listening) {
        showError('VOICE_UNAVAILABLE');
      }
    }
  }

  void setResponse(String text) {
    if (_disposed) return;
    assistantResponse = text;
    notifyListeners();
  }

  Future<void> repeatResponse() async {
    if (_disposed ||
        assistantResponse == null ||
        state == AssistantInteractionState.listening ||
        state == AssistantInteractionState.processing) {
      return;
    }
    final playback = ++_playback;
    errorCode = null;
    _setState(AssistantInteractionState.speaking);
    try {
      await _speechService.speak(assistantResponse!, languageCode);
      if (!_disposed && playback == _playback) {
        _setState(AssistantInteractionState.confirmation);
      }
    } on Exception {
      if (!_disposed && playback == _playback) {
        showError('VOICE_PLAYBACK_UNAVAILABLE');
      }
    }
  }

  void stopSpeaking() {
    if (state != AssistantInteractionState.speaking) return;
    _playback++;
    unawaited(_ignoreFailure(_speechService.stop));
    _setState(AssistantInteractionState.confirmation);
  }

  void cancelConversation() {
    _session++;
    _playback++;
    _completionTimer?.cancel();
    _recognitionStarted = false;
    unawaited(_ignoreFailure(_recognizer.cancel));
    unawaited(_ignoreFailure(_speechService.stop));
    userTranscript = null;
    assistantResponse = null;
    errorCode = null;
    _setState(AssistantInteractionState.ready);
  }

  void showError([String code = 'VOICE_UNAVAILABLE']) {
    if (_disposed) return;
    _completionTimer?.cancel();
    errorCode = code;
    unawaited(_ignoreFailure(_recognizer.cancel));
    _setState(AssistantInteractionState.error);
  }

  bool _current(int session) => !_disposed && session == _session;

  void _handleRecognitionError(int session, String code) {
    if (!_current(session) || state != AssistantInteractionState.listening) {
      return;
    }
    if (code == 'error_no_match' || code == 'error_speech_timeout') {
      _completionTimer?.cancel();
      _setState(AssistantInteractionState.ready);
      unawaited(_ignoreFailure(_recognizer.cancel));
      return;
    }
    showError(code);
  }

  void _handleStatus(int session, String status) {
    if (!_current(session) ||
        !_recognitionStarted ||
        state != AssistantInteractionState.listening) {
      return;
    }
    if (status != 'done' && status != 'notListening') return;
    // Plugin may deliver its final result shortly after the done status.
    _completionTimer?.cancel();
    _completionTimer = Timer(const Duration(milliseconds: 2500), () {
      if (_current(session) && state == AssistantInteractionState.listening) {
        _setState(AssistantInteractionState.ready);
        unawaited(_ignoreFailure(_recognizer.cancel));
      }
    });
  }

  Future<void> _handleResult(int session, String rawText, bool isFinal) async {
    if (!_current(session) || state != AssistantInteractionState.listening) {
      return;
    }
    final text = rawText.trim();
    userTranscript = text;
    if (!isFinal) {
      notifyListeners();
      return;
    }
    _completionTimer?.cancel();
    if (text.isEmpty) {
      _setState(AssistantInteractionState.ready);
      unawaited(_ignoreFailure(_recognizer.cancel));
      return;
    }
    _setState(AssistantInteractionState.processing);
    unawaited(_ignoreFailure(_recognizer.stop));
    try {
      final reply = await onTranscript?.call(text);
      if (!_current(session)) return;
      if (reply == null) {
        showError('AI_UNAVAILABLE');
        return;
      }
      assistantResponse = reply;
      completedExchangeId++;
      _setState(AssistantInteractionState.confirmation);
    } on AssistantChatException catch (error) {
      if (_current(session)) showError(error.code);
    } on Exception {
      if (_current(session)) showError('AI_UNAVAILABLE');
    }
  }

  void _setState(AssistantInteractionState value) {
    state = value;
    if (!_disposed) notifyListeners();
  }

  Future<void> _ignoreFailure(Future<void> Function() action) async {
    try {
      await action();
    } on Exception {
      // Cancelling unavailable platform resources must not create a new error.
    }
  }

  @override
  void dispose() {
    _disposed = true;
    cancelConversation();
    super.dispose();
  }
}
