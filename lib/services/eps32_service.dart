import 'piece_service.dart';
import 'session_service.dart';

class ESP32Service {
  final PieceService _pieceService = PieceService();

  /// Exécute une commande simulée sur l'ESP32 et délègue les actions de
  /// création/modification au backend Django via [PieceService] /
  /// [ModuleService].
  Future<void> executerCommande(Map<String, dynamic> commande, {String? userId}) async {
    final String action = commande['action'] ?? '';
    final List appareils = commande['appareils'] ?? [];

    // Simulation d'un délai réseau
    await Future.delayed(const Duration(seconds: 1));

    if (action == 'add') {
      final nomPiece = commande['nom'] ??
          (appareils.isNotEmpty ? appareils.first : 'nouvelle pièce');
      final typePiece = commande['type'] ?? 'général';

      final houseId = commande['houseId']?.toString() ??
          SessionService().utilisateur?.activeHouseId;
      if (houseId == null) return;

      try {
        await _pieceService.createPiece(
          nom: nomPiece,
          type: typePiece,
          houseId: houseId,
        );
      } catch (_) {
        // best effort
      }
    }
    // Les autres actions (on/off/weather) sont remontées vers l'ESP32 via
    // d'autres canaux ; côté Django on utilise plutôt l'endpoint
    // `/api/<type>s/{id}/commande` (cf. ModuleService.commande).
  }
}
