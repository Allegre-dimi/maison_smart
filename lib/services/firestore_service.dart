/// Service historique de recherche de commandes vocales multilingues.
///
/// Côté Django, la résolution de commande est gérée par
/// `POST /api/user/assistant` (cf. [CommandeParserService]). Ce stub est
/// conservé pour ne pas casser les imports existants.
class FirestoreService {
  Future<Map<String, dynamic>?> chercherCommande(String texte, String langue) async {
    return null;
  }
}
