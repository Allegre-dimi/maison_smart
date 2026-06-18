import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/theme_provider.dart';
import '../services/session_service.dart';
import 'admin_home.dart';
import 'home_page_3.dart';

class HomePage3Wrapper extends StatelessWidget {
  const HomePage3Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionService();
    final user = session.utilisateur;

    if (user == null) {
      return const Scaffold(
          body: Center(child: Text("Utilisateur non connecté")));
    }

    if (user.role == 'admin') {
      return AdminHomePage();
    }

    // Branché sur ThemeProvider pour que le toggle dark/light fonctionne.
    final tp = context.watch<ThemeProvider>();
    return HomePage3(
      utilisateur: user,
      isDarkMode: tp.isDarkMode,
      onToggleTheme: tp.toggleTheme,
    );
  }
}
