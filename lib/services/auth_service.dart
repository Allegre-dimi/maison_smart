import '../models/utilisateur.dart';
import 'api_client.dart';
import 'session_service.dart';
import 'token_storage.dart';

/// Service d'authentification basé sur les endpoints JWT Django.
///
/// Endpoints utilisés :
///   POST /api/auth/jwt/login    → access + refresh + user + utilisateur
///   POST /api/auth/jwt/refresh  → nouvelle paire (rotation)
///   POST /api/auth/jwt/logout   → blackliste le refresh
///   GET  /api/auth/me           → utilisateur courant
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiClient _api = ApiClient();
  final TokenStorage _tokens = TokenStorage();

  /// Tente de restaurer la session locale + vérifier le token côté serveur.
  /// Retourne l'utilisateur si la session est valide, null sinon.
  Future<Utilisateur?> restoreSession() async {
    await _tokens.load();
    if (!_tokens.hasSession) return null;
    try {
      final data = await _api.get('/api/auth/me') as Map<String, dynamic>;
      final u = _extractUtilisateur(data);
      SessionService().demarrerSession(u);
      return u;
    } catch (_) {
      await _tokens.clear();
      return null;
    }
  }

  /// Connexion email + mot de passe.
  Future<Utilisateur> login(String email, String password) async {
    final data = await _api.post('/api/auth/jwt/login', body: {
      'email': email.trim(),
      'password': password,
    }) as Map<String, dynamic>;

    final access = data['access'] as String?;
    final refresh = data['refresh'] as String?;
    if (access == null || refresh == null) {
      throw ApiException(500, 'Réponse de login invalide');
    }
    final u = _extractUtilisateur(data);
    await _tokens.save(access: access, refresh: refresh, userId: u.uid);
    SessionService().demarrerSession(u);
    return u;
  }

  /// Inscription d'un nouvel utilisateur.
  ///
  /// Le backend Django expose plusieurs endpoints possibles selon la version :
  /// on essaye `/api/auth/register` puis `/api/auth/signup`.
  Future<Utilisateur> register({
    required String email,
    required String password,
    required String fullName,
    required String username,
    String role = 'user',
  }) async {
    final body = {
      'email': email.trim(),
      'password': password,
      'full_name': fullName.trim(),
      'username': username.trim(),
      'role': role,
    };

    dynamic data;
    ApiException? lastError;
    for (final path in const ['/api/auth/register', '/api/auth/signup', '/api/auth/jwt/register']) {
      try {
        data = await _api.post(path, body: body);
        break;
      } on ApiException catch (e) {
        lastError = e;
        if (e.statusCode != 404 && e.statusCode != 405) rethrow;
      }
    }
    if (data == null) {
      throw lastError ?? ApiException(500, 'Aucun endpoint d\'inscription disponible');
    }
    final map = data as Map<String, dynamic>;

    // Si l'inscription renvoie déjà les tokens, on garde la session.
    if (map['access'] != null && map['refresh'] != null) {
      final u = _extractUtilisateur(map);
      await _tokens.save(
        access: map['access'] as String,
        refresh: map['refresh'] as String,
        userId: u.uid,
      );
      SessionService().demarrerSession(u);
      return u;
    }
    // Sinon on connecte explicitement.
    return login(email, password);
  }

  Future<void> logout() async {
    final refresh = _tokens.refresh;
    try {
      if (refresh != null && refresh.isNotEmpty) {
        await _api.post('/api/auth/jwt/logout', body: {'refresh': refresh});
      }
    } catch (_) {
      // logout best-effort : on nettoie quand même
    }
    await _tokens.clear();
    SessionService().fermerSession();
  }

  Future<Utilisateur> me() async {
    final data = await _api.get('/api/auth/me') as Map<String, dynamic>;
    final u = _extractUtilisateur(data);
    SessionService().demarrerSession(u);
    return u;
  }

  Utilisateur _extractUtilisateur(Map<String, dynamic> data) {
    final block = (data['utilisateur'] ?? data['user'] ?? data) as Map<String, dynamic>;
    return Utilisateur.fromJson(block);
  }
}
