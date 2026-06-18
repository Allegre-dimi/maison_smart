// lib/services/gpt_service.dart
import 'dart:math';

class GPTService {
  /// Analyse la phrase et retourne un JSON avec action, appareils et texte TTS
  Map<String, dynamic> askGPT(String phrase, String language) {
    phrase = phrase.toLowerCase().trim();
    language = language.toLowerCase();

    // 🔹 COMMANDES FRANÇAIS
    if (language.contains('fr')) {
      // Allumer / Éteindre chambre
      if (phrase.contains('allume la chambre') || phrase.contains('allume la lumière de la chambre')) {
        return {'action': 'on', 'appareils': ['chambre'], 'tts': 'Lumière de la chambre allumée'};
      }
      if (phrase.contains('éteint la chambre') || phrase.contains('éteindre la chambre') || phrase.contains('éteint la lumière de la chambre') || phrase.contains('éteins la chambre') || phrase.contains('éteins la lumière de la chambre')) {
        return {'action': 'off', 'appareils': ['chambre'], 'tts': 'Lumière de la chambre éteinte'};
      }

      // Cuisine
      if (phrase.contains('allume la cuisine') || phrase.contains('allume la lumière de la cuisine')) {
        return {'action': 'on', 'appareils': ['cuisine'], 'tts': 'Lumière de la cuisine allumée'};
      }
      if (phrase.contains('éteint la cuisine') || phrase.contains('éteindre la cuisine') || phrase.contains('éteint la lumière de la cuisine') || phrase.contains('éteins la cuisine') || phrase.contains('éteins la lumière de la cuisine')) {
        return {'action': 'off', 'appareils': ['cuisine'], 'tts': 'Lumière de la cuisine éteinte'};
      }

      // Salon
      if (phrase.contains('allume le salon') || phrase.contains('allume la lumière du salon')) {
        return {'action': 'on', 'appareils': ['salon'], 'tts': 'Lumière du salon allumée'};
      }
      if (phrase.contains('éteint le salon') || phrase.contains('éteindre le salon') || phrase.contains('éteint la lumière du salon') || phrase.contains('éteins le salon') || phrase.contains('éteins la lumière du salon')) {
        return {'action': 'off', 'appareils': ['salon'], 'tts': 'Lumière du salon éteinte'};
      }

      // Climatisation
      if (phrase.contains('allume la clim') || phrase.contains('allume la climatisation')) {
        return {'action': 'on', 'appareils': ['clim'], 'tts': 'Climatisation allumée'};
      }
      if (phrase.contains('éteint la clim') || phrase.contains('éteindre la clim') || phrase.contains('éteint la climatisation')) {
        return {'action': 'off', 'appareils': ['clim'], 'tts': 'Climatisation éteinte'};
      }

      // Tout allumer / Tout éteindre
      if (phrase.contains('allume tout') || phrase.contains('allume toutes les lumières')) {
        return {'action': 'on', 'appareils': ['toutes'], 'tts': 'Toutes les lumières sont allumées'};
      }
      if (phrase.contains('éteint tout') || phrase.contains('éteint toutes les lumières')) {
        return {'action': 'off', 'appareils': ['toutes'], 'tts': 'Toutes les lumières sont éteintes'};
      }

      // Ajouter une pièce
      if (phrase.contains('ajoute une pièce') || phrase.contains('ajouter une pièce')) {
        // Extraction simple du nom et type (ex: "ajoute une pièce de type salon de nom ami")
        final regex = RegExp(r'de type (\w+) de nom (\w+)', caseSensitive: false);
        final match = regex.firstMatch(phrase);
        String nom = 'nouvelle pièce';
        String type = 'général';
        if (match != null) {
          type = match.group(1)!;
          nom = match.group(2)!;
        }
        return {'action': 'add', 'appareils': [nom], 'type': type, 'tts': "Pièce '$nom' ajoutée"};
      }

      // Météo
      if (phrase.contains('météo') || phrase.contains('quel temps fait-il')) {
        final randomTemp = Random().nextInt(30); // 0 à 29°C
        return {'action': 'weather', 'temperature': randomTemp, 'tts': "La température est de $randomTemp degrés"};
      }
    }

    // 🔹 COMMANDES LINGALA
    if (language.contains('lingala')) {
      if (phrase.contains('pelissa chambre') || phrase.contains('pelissa mwinda ya chambre') || phrase.contains('Mélissa mwinda ya chambre') || phrase.contains('Mélissa mouya chambre') || phrase.contains('Mélissa mwindaya chambre')) {
        return {'action': 'on', 'appareils': ['chambre'], 'tts': 'Mwinda ya chambre epeli'};
      }
      if (phrase.contains('boma chambre') || phrase.contains('boma mwinda ya chambre')) {
        return {'action': 'off', 'appareils': ['chambre'], 'tts': ' Na bomi mwinda ya chambre'};
      }

      if (phrase.contains('pelissa cuisine') || phrase.contains('pelissa mwinda ya cuisine') || phrase.contains('Mélissa mwinda ya cuisine') || phrase.contains('Mélissa mouya cuisine') || phrase.contains('Mélissa mwindaya cuisine')) {
        return {'action': 'on', 'appareils': ['cuisine'], 'tts': 'Mwinda ya cuisine epeli'};
      }
      if (phrase.contains('boma cuisine') || phrase.contains('boma mwinda ya cuisine')) {
        return {'action': 'off', 'appareils': ['cuisine'], 'tts': 'Na bomi mwinda ya cuisine'};
      }

      if (phrase.contains('pelissa salon') || phrase.contains('pelissa mwinda ya salon') || phrase.contains('Mélissa mwinda ya salon') || phrase.contains('Mélissa mouya salon') || phrase.contains('Mélissa mwindaya salon')) {
        return {'action': 'on', 'appareils': ['salon'], 'tts': 'Mwinda ya salon epeli'};
      }
      if (phrase.contains('boma salon') || phrase.contains('boma mwinda ya salon')) {
        return {'action': 'off', 'appareils': ['salon'], 'tts': 'Na bomi mwinda ya salon'};
      }

      if (phrase.contains('pelissa clim') || phrase.contains('pelissa climatisation')) {
        return {'action': 'on', 'appareils': ['clim'], 'tts': 'Climatisation epeli'};
      }
      if (phrase.contains('boma clim')) {
        return {'action': 'off', 'appareils': ['clim'], 'tts': ' Na bomi Climatisation'};
      }

      if (phrase.contains('pelissa mwinda niosso')) {
        return {'action': 'on', 'appareils': ['toutes'], 'tts': 'Na pelissi ba miwinda nyonso tout ya ndako'};
      }
      if (phrase.contains('boma mwinda niosso')) {
        return {'action': 'off', 'appareils': ['toutes'], 'tts': 'Na bomi ba miwinda nyonso tout ya ndako'};
      }

      if (phrase.contains('bakissa piece')) {
        final nom = 'na bakissi piece';
        return {'action': 'add', 'appareils': [nom], 'type': 'général', 'tts': "Pièce '$nom' ajoutée"};
      }

      if (phrase.contains('pessa meteo ya lelo') || phrase.contains('pessa meteo yalo') || phrase.contains('Bessa meto y a lelo') || phrase.contains('PSA meteo y a lelo') || phrase.contains('Pesa meteo y a lilo') || phrase.contains('pessa meteo ya lilo') || phrase.contains('pessa meteo y a lilo')) {
        final randomTemp = Random().nextInt(30);
        return {'action': 'weather', 'temperature': randomTemp, 'tts': "Temperature ezali $randomTemp degres"};
      }
    }

    // 🔹 COMMANDES ANGLAIS
    if (language.contains('en')) {
      if (phrase.contains('turn on bedroom') || phrase.contains('turn on the bedroom light')) {
        return {'action': 'on', 'appareils': ['chambre'], 'tts': 'Bedroom light turned on'};
      }
      if (phrase.contains('turn off bedroom') || phrase.contains('turn off the bedroom light')) {
        return {'action': 'off', 'appareils': ['chambre'], 'tts': 'Bedroom light turned off'};
      }

      if (phrase.contains('turn on kitchen') || phrase.contains('turn on the kitchen light')) {
        return {'action': 'on', 'appareils': ['cuisine'], 'tts': 'Kitchen light turned on'};
      }
      if (phrase.contains('turn off kitchen') || phrase.contains('turn off the kitchen light')) {
        return {'action': 'off', 'appareils': ['cuisine'], 'tts': 'Kitchen light turned off'};
      }

      if (phrase.contains('turn on living room') || phrase.contains('turn on the living room light')) {
        return {'action': 'on', 'appareils': ['salon'], 'tts': 'Living room light turned on'};
      }
      if (phrase.contains('turn off living room') || phrase.contains('turn off the living room light')) {
        return {'action': 'off', 'appareils': ['salon'], 'tts': 'Living room light turned off'};
      }

      if (phrase.contains('turn on ac') || phrase.contains('turn on the ac')) {
        return {'action': 'on', 'appareils': ['clim'], 'tts': 'AC turned on'};
      }
      if (phrase.contains('turn off ac') || phrase.contains('turn off the ac')) {
        return {'action': 'off', 'appareils': ['clim'], 'tts': 'AC turned off'};
      }

      if (phrase.contains('turn on all') || phrase.contains('turn on all lights')) {
        return {'action': 'on', 'appareils': ['toutes'], 'tts': 'All lights turned on'};
      }
      if (phrase.contains('turn off all') || phrase.contains('turn off all lights')) {
        return {'action': 'off', 'appareils': ['toutes'], 'tts': 'All lights turned off'};
      }

      if (phrase.contains('add new room') || phrase.contains('add room')) {
        final nom = 'bathroom';
        return {'action': 'add', 'appareils': [nom], 'type': 'général', 'tts': "Room '$nom' added"};
      }

      if (phrase.contains('weather') || phrase.contains('what’s the weather today')) {
        final randomTemp = Random().nextInt(30);
        return {'action': 'weather', 'temperature': randomTemp, 'tts': "The temperature is $randomTemp degrees"};
      }
    }

    // ❌ Si aucune commande reconnue
    if (language.contains('lingala')) {
      return {'action': 'unknown', 'tts': 'Nakoki te koyoka eloko olobi'};
    }
    if (language.contains('en')) {
      return {'action': 'unknown', 'tts': 'I did not understand the command'};
    }
    return {'action': 'unknown', 'tts': 'Je n’ai pas compris la commande'};
  }
}
