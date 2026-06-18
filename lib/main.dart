import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/auth_gate.dart';
import 'screens/theme_provider.dart';
import 'services/auth_service.dart';
import 'services/session_service.dart';
import 'services/token_storage.dart';
import 'theme/app_theme.dart';
import 'views/admin_home.dart';
import 'views/inscription_page.dart';
import 'views/login_page.dart';
import 'views/select_house_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenStorage().load();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const NdakoApp(),
    ),
  );
}

class NdakoApp extends StatelessWidget {
  const NdakoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    AppTheme.applySystemUi(isDark: themeProvider.isDarkMode);

    return MaterialApp(
      title: 'Ndako',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      home: const AuthGate(),
      routes: {
        '/admin': (_) => AdminHomePage(),
        '/user': (_) => _UserRoute(),
        '/inscription': (_) => InscriptionPage(),
        '/login': (_) => const ConnexionPage(),
      },
    );
  }
}

class _UserRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final current = SessionService().utilisateur;
    if (current != null) {
      return SelectHousePage(utilisateur: current);
    }
    // Pas de session en mémoire — on retente une restauration silencieuse.
    return FutureBuilder(
      future: AuthService().restoreSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final u = snapshot.data;
        if (u == null) return const ConnexionPage();
        return SelectHousePage(utilisateur: u);
      },
    );
  }
}
