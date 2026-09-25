import 'package:speech_to_text/speech_to_text.dart';

abstract interface class AssistantSpeechRecognizer {
  Future<bool> initialize({
    required void Function(String) onError,
    required void Function(String) onStatus,
  });

  Future<void> listen({
    required String languageCode,
    required void Function(String, bool) onResult,
  });

  Future<void> stop();
  Future<void> cancel();
}

class AssistantSpeechRecognitionException implements Exception {
  const AssistantSpeechRecognitionException(this.code);
  final String code;
}

/// One platform recognizer per app session; callbacks are rebound per owner.
class DeviceAssistantSpeechRecognizer implements AssistantSpeechRecognizer {
  DeviceAssistantSpeechRecognizer._();

  static final instance = DeviceAssistantSpeechRecognizer._();
  final SpeechToText _speech = SpeechToText();
  void Function(String)? _onError;
  void Function(String)? _onStatus;
  int _generation = 0;

  @override
  Future<bool> initialize({
    required void Function(String) onError,
    required void Function(String) onStatus,
  }) {
    _onError = onError;
    _onStatus = onStatus;
    return _speech.initialize(
      options: [SpeechToText.androidNoBluetooth],
      onError: (error) => _onError?.call(error.errorMsg),
      onStatus: (status) => _onStatus?.call(status),
    );
  }

  @override
  Future<void> listen({
    required String languageCode,
    required void Function(String, bool) onResult,
  }) async {
    final generation = ++_generation;
    final locales = await _speech.locales();
    if (generation != _generation) return;
    final matching = locales.where(
      (locale) =>
          locale.localeId.toLowerCase().split(RegExp('[-_]')).first ==
          languageCode,
    );
    if (matching.isEmpty) {
      throw const AssistantSpeechRecognitionException(
        'VOICE_LANGUAGE_UNAVAILABLE',
      );
    }
    await _speech.listen(
      onResult: (result) {
        if (generation == _generation) {
          onResult(result.recognizedWords, result.finalResult);
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: matching.first.localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      ),
    );
    if (generation != _generation) {
      await _speech.cancel();
      return;
    }
    if (!_speech.isListening) {
      throw const AssistantSpeechRecognitionException('VOICE_UNAVAILABLE');
    }
  }

  @override
  Future<void> stop() async => _speech.stop();

  @override
  Future<void> cancel() async {
    _generation++;
    await _speech.cancel();
  }
}
