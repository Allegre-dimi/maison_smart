// admin_home.dart
import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class AdminHomePage extends StatelessWidget {
  final AuthController authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - Tableau de bord'),
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
      body: Center(child: Text('Bienvenue Admin !')),
    );
  }
}
