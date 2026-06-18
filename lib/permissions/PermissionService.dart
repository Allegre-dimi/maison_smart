import '../models/maison.dart';
import '../services/maison_service.dart';
import '../services/session_service.dart';

/// Service de permissions adapté au backend Django.
///
/// Côté Django, les permissions par pièce ne sont pas (encore) modélisées :
/// on s'appuie sur les rôles owner/admin/member calculés sur la maison.
class PermissionService {
  static final MaisonService _maisonService = MaisonService();

  static Future<Maison?> _maison(String houseId) async {
    final cached = SessionService().utilisateur;
    if (cached != null) {
      // Pas de cache en mémoire — on retourne directement la requête.
    }
    return await _maisonService.getMaison(houseId);
  }

  static Future<Map<String, dynamic>> getUserPermissions(
      String houseId, String userId) async {
    final m = await _maison(houseId);
    if (m == null) throw 'Maison introuvable.';
    final role = m.roleUtilisateur ?? _computeRole(m, userId);
    return {
      'role': role,
      'addDevice': role == 'owner' || role == 'admin',
      'pieces': const <String, bool>{},
    };
  }

  static Future<bool> canAddDevice(String houseId, String userId) async {
    final m = await _maison(houseId);
    if (m == null) throw 'Maison introuvable.';
    final role = m.roleUtilisateur ?? _computeRole(m, userId);
    return role == 'owner' || role == 'admin';
  }

  static Future<bool> canAccessPiece(
      String houseId, String userId, String pieceId) async {
    final m = await _maison(houseId);
    if (m == null) throw 'Maison introuvable.';
    final role = m.roleUtilisateur ?? _computeRole(m, userId);
    // Owner/admin : accès à toutes les pièces. Membre : accès via API
    // (filtrage côté serveur ; toute pièce listée est accessible).
    return role == 'owner' || role == 'admin' || role == 'member';
  }

  static Future<String> getUserRole(String houseId, String userId) async {
    final m = await _maison(houseId);
    if (m == null) throw 'Maison introuvable.';
    final role = m.roleUtilisateur ?? _computeRole(m, userId);
    switch (role) {
      case 'owner':
        return 'propriétaire';
      case 'admin':
        return 'admin';
      default:
        return 'membre';
    }
  }

  /// Mise à jour de permission — non supporté par Django pour l'instant.
  static Future<void> updatePermission(
    String houseId,
    String userId,
    String permissionType,
    String? itemId,
    bool value,
  ) async {
    throw UnimplementedError(
        "La gestion fine des permissions n'est pas encore disponible côté backend.");
  }

  static String _computeRole(Maison m, String userId) {
    if (m.ownerId == userId) return 'owner';
    if ((m.adminIds ?? const []).contains(userId)) return 'admin';
    if ((m.members ?? const []).contains(userId)) return 'member';
    return 'member';
  }
}
