// lib/services/tts_service.dart
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _tts = FlutterTts();

  /// Fait parler le téléphone dans la langue donnée
  /// [languageCode] peut être 'français', 'anglais', ou 'lingala'
  Future<void> speak(String text, String languageCode) async {
    if (text.isEmpty) return;

    languageCode = languageCode.toLowerCase();

    // 🔤 Détecte le code de langue exact pour FlutterTTS
    String lang = _getLangCode(languageCode);

    print("🔊 TTS parle en $lang : $text");

    await _tts.setLanguage(lang);
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.9);
    await _tts.speak(text);
  }

  /// Détermine le code de langue exact pour FlutterTTS
  String _getLangCode(String code) {
    code = code.toLowerCase();
    if (code.contains('fr')) return 'fr-FR';           // Français
    if (code.contains('angl')) return 'en-US';         // Anglais
    if (code.contains('lingala') || code.contains('ln')) return 'fr-FR'; // Lingala → voix française
    return 'fr-FR';
  }

  /// Stoppe la parole
  Future<void> stop() async {
    await _tts.stop();
  }
}
