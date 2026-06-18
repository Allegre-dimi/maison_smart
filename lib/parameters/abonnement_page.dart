import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Page d'abonnement.
///
/// Côté Django, l'app `payments` existe (modèle `Payment`) mais n'expose
/// pas encore d'API publique pour la gestion des abonnements. Cette page
/// affiche l'état actuel et permettra la saisie une fois les endpoints
/// disponibles.
class AbonnementPage extends StatelessWidget {
  const AbonnementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Abonnement",
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.credit_card, color: Colors.deepPurple),
                title: Text("Abonnement Ndako"),
                subtitle: Text(
                    "La gestion des abonnements arrive bientôt côté backend Django."),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Plans prévus :\n• Mensuel — 6 559 CFA\n• Trimestriel — 16 399 CFA\n• Annuel — 65 595 CFA",
              style: TextStyle(fontSize: 14),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.payment),
              label: const Text("Souscrire (bientôt disponible)"),
            ),
          ],
        ),
      ),
    );
  }
}
