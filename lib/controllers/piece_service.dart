import '../models/piece.dart';
import '../services/piece_service.dart' as core;
import '../services/session_service.dart';

/// Service "controller" historique — délègue au [core.PieceService].
class PieceService {
  final core.PieceService _impl = core.PieceService();

  Future<String> ajouterPiece(String nom, String type) async {
    final houseId = SessionService().utilisateur?.activeHouseId;
    if (houseId == null) {
      throw Exception("Aucune maison active.");
    }
    final piece = await _impl.ajouterPiece(nom, type, '', houseId: houseId);
    return piece.id;
  }

  Future<List<Piece>> getPieces() async {
    final houseId = SessionService().utilisateur?.activeHouseId;
    return _impl.listPieces(houseId: houseId);
  }
}
