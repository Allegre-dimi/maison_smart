// user_home.dart
import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class UserHomePage extends StatelessWidget {
  final AuthController authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Utilisateur - Accueil'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authController.deconnexion();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          )
        ],
      ),
      body: Center(child: Text('Bienvenue Utilisateur !')),
    );
  }
}
