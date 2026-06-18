import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../views/login_page.dart';
import '../views/select_house_page.dart';

/// Point d'entrée après init : essaye de restaurer la session JWT, puis route
/// vers la page de sélection de maison ou la page de connexion.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService().restoreSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final utilisateur = snapshot.data;
        if (utilisateur == null) {
          return const ConnexionPage();
        }
        return SelectHousePage(utilisateur: utilisateur);
      },
    );
  }
}
