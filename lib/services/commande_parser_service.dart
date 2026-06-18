// FILE: lib/services/commande_parser_service.dart
//
// Délègue désormais le NLU à l'endpoint Django `POST /api/user/assistant`.
// Le backend prend en charge la détection d'intent (on/off/set/query),
// la résolution des modules, la vérification des permissions et la
// diffusion WebSocket. On garde l'API publique du service pour que les
// écrans existants continuent à fonctionner sans modification.

import '../services/api_client.dart';
import '../services/session_service.dart';

class CommandeParserService {
  // Flags conversationnels conservés pour rétro-compat (non utilisés —
  // le backend porte tout l'état).
  bool isAwaitingRoomName = false;
  String? pendingRoomType;
  bool isAwaitingDeviceName = false;
  String? pendingDeviceType;
  String? pendingDevicePieceId;
  String? pendingDevicePieceName;
  String? pendingLang;

  String esp32Ip = "192.168.1.50";

  /// Dernier résultat — exposé pour que `HomePage3` puisse pousser un
  /// signal IR/ESP32 si besoin.
  String? lastAction;
  List<String> lastTargets = [];

  String? lastIntent;
  String? lastPieceId;
  String? lastPieceName;
  String? lastDeviceType;

  final ApiClient _api = ApiClient();

  Future<String> analyserCommande(
    String commande,
    String langue, {
    String? userId,
    String? houseId,
  }) async {
    final effectiveHouseId =
        houseId ?? SessionService().utilisateur?.activeHouseId;

    final body = <String, dynamic>{
      'texte': commande,
      if (effectiveHouseId != null) 'maison_id': effectiveHouseId,
      if (lastPieceId != null) 'piece_id': lastPieceId,
      'langue': langue,
    };

    try {
      final data = await _api.post('/api/user/assistant', body: body);
      if (data is! Map<String, dynamic>) {
        return _fallbackMessage(langue);
      }

      final reponse = (data['reponse'] ?? data['response'] ?? '').toString();

      // Mise à jour du contexte conversationnel.
      final intent = data['intent']?.toString();
      if (intent != null) lastIntent = intent;
      final pieceId = data['piece_id']?.toString();
      if (pieceId != null) lastPieceId = pieceId;
      final pieceName = data['piece_nom']?.toString();
      if (pieceName != null) lastPieceName = pieceName;

      final module = data['module'];
      if (module is Map<String, dynamic>) {
        final etat = module['etat'];
        if (etat is bool) {
          lastAction = etat ? 'on' : 'off';
        }
        final nom = module['nom']?.toString();
        if (nom != null && nom.isNotEmpty) {
          lastTargets = [nom];
        }
        final type = module['type']?.toString();
        if (type != null) lastDeviceType = type;
      }

      if (reponse.isNotEmpty) return reponse;
      return _conversationFallback(langue, data['ok'] == true);
    } on ApiException catch (e) {
      if (e.statusCode == 400 && e.body is Map<String, dynamic>) {
        final body = e.body as Map<String, dynamic>;
        final r = (body['reponse'] ?? body['error'] ?? '').toString();
        if (r.isNotEmpty) return r;
      }
      return _onError(e, langue);
    } catch (e) {
      return _fallbackMessage(langue);
    }
  }

  String _fallbackMessage(String langue) {
    switch (langue) {
      case 'en':
        return "Sorry, I didn't catch that.";
      case 'ln':
        return "Nayoki te.";
      default:
        return "Je n'ai pas compris.";
    }
  }

  String _conversationFallback(String langue, bool ok) {
    if (ok) {
      switch (langue) {
        case 'en':
          return "Done.";
        case 'ln':
          return "Esili.";
        default:
          return "C'est fait.";
      }
    }
    return _fallbackMessage(langue);
  }

  String _onError(ApiException e, String langue) {
    if (e.statusCode == 0) {
      switch (langue) {
        case 'en':
          return "I can't reach the server right now.";
        case 'ln':
          return "Nazwi serveur te sik'oyo.";
        default:
          return "Je ne joins pas le serveur pour l'instant.";
      }
    }
    return e.message;
  }
}
