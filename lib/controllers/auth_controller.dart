import '../models/utilisateur.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

/// Couche d'accès historique de l'auth.
///
/// L'implémentation passe désormais par [AuthService] (Django/JWT) ; les
/// signatures publiques sont conservées pour limiter les modifications dans
/// les écrans existants.
class AuthController {
  final AuthService _auth = AuthService();

  /// Inscription d'un nouvel utilisateur.
  /// Retourne null si OK, sinon un message d'erreur lisible.
  Future<String?> inscrire(
    String email,
    String mdp,
    String role, {
    required String nom,
    required String username,
  }) async {
    try {
      await _auth.register(
        email: email,
        password: mdp,
        fullName: nom,
        username: username,
        role: role,
      );
      return null;
    } on ApiException catch (e) {
      return _humanizeError(e);
    } catch (e) {
      return "Erreur inattendue : $e";
    }
  }

  /// Connexion email + mot de passe.
  /// Lève une [ApiException] en cas d'erreur (parité avec l'ancienne API).
  Future<Utilisateur?> connexion(String email, String mdp) async {
    return await _auth.login(email, mdp);
  }

  /// Recherche d'un utilisateur par username — déprécié.
  /// Retourne null (le backend Django ne l'expose pas par défaut).
  Future<dynamic> getUserByUsername(String username) async => null;

  Future<void> deconnexion() => _auth.logout();

  String _humanizeError(ApiException e) {
    final body = e.body;
    if (body is Map<String, dynamic>) {
      if (body['email'] is List) {
        return (body['email'] as List).join(' ');
      }
      if (body['username'] is List) {
        return (body['username'] as List).join(' ');
      }
      if (body['password'] is List) {
        return (body['password'] as List).join(' ');
      }
    }
    return e.message;
  }
}
