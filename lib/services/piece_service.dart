import '../models/piece.dart';
import 'api_client.dart';

/// Service CRUD pour les pièces.
/// Endpoints Django :
///   GET    /api/pieces/?maison={id}
///   GET    /api/pieces/{id}/
///   POST   /api/pieces/
///   PUT    /api/pieces/{id}/
///   DELETE /api/pieces/{id}/
class PieceService {
  final ApiClient _api = ApiClient();

  Future<List<Piece>> listPieces({String? houseId}) async {
    final data = await _api.get(
      '/api/pieces/',
      query: houseId == null ? null : {'maison': houseId},
    );
    final items = _results(data);
    return items.map((e) => Piece.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Piece?> getPiece(String pieceId) async {
    try {
      final data = await _api.get('/api/pieces/$pieceId/') as Map<String, dynamic>;
      return Piece.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Création d'une pièce.
  ///
  /// `userId` est conservé pour compat (ancien appel `ajouterPiece(nom,type,userId)`)
  /// mais Django récupère l'utilisateur via le JWT — on l'ignore donc.
  Future<Piece> ajouterPiece(String nom, String type, String userId,
      {required String houseId, String iconeName = 'Autre'}) async {
    final body = <String, dynamic>{
      'nom': nom,
      'type': type,
      'maison_id': houseId,
      'icone_font_family': 'MaterialIcons',
      'icone_code_point': _iconCodePoint(iconeName),
    };
    final data = await _api.post('/api/pieces/', body: body) as Map<String, dynamic>;
    return Piece.fromJson(data);
  }

  Future<Piece> createPiece({
    required String nom,
    required String type,
    required String houseId,
    String iconeName = 'Autre',
  }) =>
      ajouterPiece(nom, type, '', houseId: houseId, iconeName: iconeName);

  Future<Piece> mettreAJourPiece(String pieceId, Map<String, dynamic> data) async {
    final body = <String, dynamic>{};
    data.forEach((k, v) {
      // Map des anciens noms Firestore vers les nouveaux noms Django
      switch (k) {
        case 'houseId':
          body['maison_id'] = v;
          break;
        case 'userId':
          // userId est défini par Django via le JWT
          break;
        case 'iconeName':
          body['icone_font_family'] = 'MaterialIcons';
          body['icone_code_point'] = _iconCodePoint(v as String);
          break;
        default:
          body[k] = v;
      }
    });
    final updated =
        await _api.put('/api/pieces/$pieceId/', body: body) as Map<String, dynamic>;
    return Piece.fromJson(updated);
  }

  Future<void> supprimerPiece(String pieceId) async {
    await _api.delete('/api/pieces/$pieceId/');
  }

  List _results(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      if (data['results'] is List) return data['results'] as List;
    }
    return const [];
  }

  // Petite table de correspondance — voir `Piece.icon`.
  int _iconCodePoint(String name) {
    // Évite d'importer Flutter ici : valeurs des MaterialIcons.
    const map = {
      'Salon': 0xe533,        // Icons.weekend
      'Cuisine': 0xe320,      // Icons.kitchen
      'Chambre': 0xe0d8,      // Icons.bed
      'Couloir': 0xe0d8,
      'Salle de bain': 0xe5c0,
      'Bureau': 0xe8f9,
      'Garage': 0xe9c4,
      'Balcon': 0xe588,
      'Entrée': 0xe5cb,
      'Salle à manger': 0xe5cd,
      'Autre': 0xe531,
    };
    return map[name] ?? map['Autre']!;
  }
}
