import '../models/utilisateur.dart';
import 'token_storage.dart';

/// Stockage en mémoire de l'utilisateur connecté (singleton).
///
/// L'`activeHouseId` est miroir entre l'objet Utilisateur et le
/// [TokenStorage] (persisté entre lancements de l'app).
class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  Utilisateur? utilisateur;

  bool get estConnecte => utilisateur != null;

  void demarrerSession(Utilisateur user) {
    utilisateur = user;
    final cached = TokenStorage().activeHouseId;
    if (cached != null && cached.isNotEmpty) {
      user.activeHouseId = cached;
    }
  }

  void fermerSession() {
    utilisateur = null;
  }

  Future<void> setActiveHouse(String? houseId) async {
    utilisateur?.activeHouseId = houseId;
    await TokenStorage().setActiveHouseId(houseId);
  }
}
