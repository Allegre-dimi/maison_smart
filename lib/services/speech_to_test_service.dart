import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  String _lastWords = '';
  Completer<String>? _currentCompleter;

  /// Initialise le micro
  Future<void> init() async {
    _isAvailable = await _speech.initialize(
      onStatus: (status) => print("STT Status: $status"),
      onError: (errorNotification) => print("STT Error: ${errorNotification.errorMsg}"),
    );
  }

  /// Écoute la voix et retourne le texte reconnu.
  /// [onPartial] est appelé à chaque mise à jour intermédiaire, ce qui
  /// permet à l'UI d'afficher la transcription en direct et de récupérer
  /// le texte courant si l'utilisateur valide avant la fin (bouton OK).
  Future<String> listen({
    required String localeId,
    Duration maxListenDuration = const Duration(seconds: 8),
    void Function(String partial)? onPartial,
  }) async {
    await init();
    if (!_isAvailable) return "";

    _lastWords = '';
    _isListening = true;
    final completer = Completer<String>();
    _currentCompleter = completer;

    _speech.listen(
      localeId: localeId,
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      onResult: (result) {
        _lastWords = result.recognizedWords;
        if (onPartial != null) onPartial(_lastWords);
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

  /// Arrête manuellement l’écoute et débloque [listen] avec le texte
  /// reconnu jusqu’ici (utile quand l’utilisateur valide via "OK").
  Future<String> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    _isListening = false;
    final completer = _currentCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(_lastWords);
    }
    _currentCompleter = null;
    return _lastWords;
  }

  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;
}
