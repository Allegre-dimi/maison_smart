import '../models/maison.dart';
import '../models/module.dart';
import '../models/piece.dart';
import 'api_client.dart';

/// Service CRUD pour les maisons (et accès aux ressources liées).
/// Endpoints Django :
///   GET    /api/maisons/
///   GET    /api/maisons/{id}/
///   POST   /api/maisons/
///   PUT    /api/maisons/{id}/
///   DELETE /api/maisons/{id}/
///   GET    /api/maisons/{id}/pieces
///   GET    /api/maisons/{id}/modules
///   GET    /api/maisons/{id}/invitations
///   POST   /api/maisons/{id}/invitations
///   POST   /api/invitations/accept
///   DELETE /api/invitations/{id}/
class MaisonService {
  final ApiClient _api = ApiClient();

  Future<List<Maison>> listMaisons() async {
    final data = await _api.get('/api/maisons/');
    final items = _extractResults(data);
    return items
        .map((e) => Maison.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Maison?> getMaison(String houseId) async {
    try {
      final data = await _api.get('/api/maisons/$houseId/') as Map<String, dynamic>;
      return Maison.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Maison> createMaison({
    required String name,
    String? adresse,
    String? ville,
    String? pays,
    String? telephone,
    String? code,
    String? description,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      if (adresse != null) 'adresse': adresse,
      if (ville != null) 'ville': ville,
      if (pays != null) 'pays': pays,
      if (telephone != null) 'telephone': telephone,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
    };
    final data = await _api.post('/api/maisons/', body: body) as Map<String, dynamic>;
    return Maison.fromJson(data);
  }

  Future<Maison> updateMaison(String houseId, Map<String, dynamic> patch) async {
    final data = await _api.put('/api/maisons/$houseId/', body: patch)
        as Map<String, dynamic>;
    return Maison.fromJson(data);
  }

  Future<void> deleteMaison(String houseId) async {
    await _api.delete('/api/maisons/$houseId/');
  }

  Future<List<Piece>> getPiecesByMaison(String houseId) async {
    final data = await _api.get('/api/maisons/$houseId/pieces');
    final list = data is List ? data : _extractResults(data);
    return list
        .map((e) => Piece.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Module>> getModulesByMaison(String houseId, {String? type}) async {
    final data = await _api.get(
      '/api/maisons/$houseId/modules',
      query: type == null ? null : {'type': type},
    );
    final list = data is List ? data : _extractResults(data);
    return list
        .map((e) => Module.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Rejoindre une maison via un code d'invitation.
  Future<Maison> acceptInvitation(String code) async {
    final data = await _api.post('/api/invitations/accept/', body: {'code': code})
        as Map<String, dynamic>;
    final block = (data['maison'] ?? data) as Map<String, dynamic>;
    return Maison.fromJson(block);
  }

  Future<Map<String, dynamic>> createInvitation(
    String houseId, {
    String role = 'member',
    int expiresInDays = 7,
  }) async {
    return await _api.post('/api/maisons/$houseId/invitations/', body: {
      'role': role,
      'expires_in_days': expiresInDays,
    }) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listInvitations(String houseId) async {
    final data = await _api.get('/api/maisons/$houseId/invitations/');
    final list = data is List ? data : _extractResults(data);
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> revokeInvitation(int invitationId) async {
    await _api.delete('/api/invitations/$invitationId/');
  }

  List _extractResults(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      if (data['results'] is List) return data['results'] as List;
      if (data['data'] is List) return data['data'] as List;
    }
    return const [];
  }
}
