import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  String _lastWords = '';

  /// Initialise le micro
  Future<void> init() async {
    _isAvailable = await _speech.initialize(
      onStatus: (status) => print("STT Status: $status"),
      onError: (errorNotification) => print("STT Error: ${errorNotification.errorMsg}"),
    );
  }

  /// Écoute la voix et retourne le texte reconnu
  Future<String> listen({
    required String localeId,
    Duration maxListenDuration = const Duration(seconds: 8),
  }) async {
    await init();
    if (!_isAvailable) return "";

    _lastWords = '';
    _isListening = true;
    final completer = Completer<String>();

    _speech.listen(
      localeId: localeId,
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      onResult: (result) {
        _lastWords = result.recognizedWords;
        if (result.finalResult) {
          _isListening = false;
          if (!completer.isCompleted) completer.complete(_lastWords);
        }
      },
      listenFor: maxListenDuration,
      cancelOnError: true,
    );

    // Sécurité : arrête après maxListenDuration
    Future.delayed(maxListenDuration, () {
      if (_speech.isListening) _speech.stop();
      if (_isListening) {
        _isListening = false;
        if (!completer.isCompleted) completer.complete(_lastWords);
      }
    });

    return completer.future;
  }

  /// Arrête manuellement l’écoute
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
      _isListening = false;
      print("Écoute stoppée manuellement");
    }
  }

  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;
}
