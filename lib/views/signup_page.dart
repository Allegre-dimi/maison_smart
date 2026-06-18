import 'package:flutter/material.dart';

import '../models/utilisateur.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import 'creation_ou_connexion_maison_page.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({Key? key}) : super(key: key);

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String username = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  bool isLoading = false;
  String errorMessage = '';
  bool _obscureText = true;
  bool _obscureConfirmText = true;

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final Utilisateur newUser = await AuthService().register(
        email: email.trim(),
        password: password.trim(),
        fullName: fullName.trim(),
        username: username.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CreationOuConnexionMaisonPage(utilisateur: newUser),
        ),
      );
    } on ApiException catch (e) {
      String message;
      final body = e.body;
      if (body is Map<String, dynamic>) {
        if (body['email'] is List && (body['email'] as List).isNotEmpty) {
          message = (body['email'] as List).first.toString();
        } else if (body['username'] is List && (body['username'] as List).isNotEmpty) {
          message = (body['username'] as List).first.toString();
        } else if (body['password'] is List && (body['password'] as List).isNotEmpty) {
          message = (body['password'] as List).first.toString();
        } else {
          message = e.message;
        }
      } else {
        message = e.message;
      }
      setState(() => errorMessage = message);
    } catch (e) {
      setState(() => errorMessage = "Erreur inconnue : $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required bool obscure,
    required Function(String) onChanged,
    IconData? icon,
    bool isConfirm = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        obscureText: obscure,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.black),
        cursorColor: Colors.deepPurple,
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return 'Ce champ est requis';
          }
          if (isConfirm && val != password) {
            return 'Les mots de passe ne correspondent pas';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: icon != null ? Icon(icon, color: Colors.deepPurple) : null,
          suffixIcon: label.contains("Mot de passe")
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility : Icons.visibility_off,
                    color: Colors.deepPurple,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isConfirm) {
                        _obscureConfirmText = !_obscureConfirmText;
                      } else {
                        _obscureText = !_obscureText;
                      }
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 4,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Inscription",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.person_add, size: 80, color: Colors.white70),
                const SizedBox(height: 20),
                const Text(
                  "Créez votre compte",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Inscrivez-vous pour protéger votre compte et accéder à votre maison connectée.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 30),
                if (errorMessage.isNotEmpty)
                  Text(errorMessage, style: const TextStyle(color: Colors.red)),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                          label: "Nom complet",
                          obscure: false,
                          onChanged: (val) => fullName = val,
                          icon: Icons.person),
                      _buildTextField(
                          label: "Nom d’utilisateur",
                          obscure: false,
                          onChanged: (val) => username = val,
                          icon: Icons.person_outline),
                      _buildTextField(
                          label: "Adresse email",
                          obscure: false,
                          onChanged: (val) => email = val,
                          icon: Icons.email),
                      _buildTextField(
                          label: "Mot de passe",
                          obscure: _obscureText,
                          onChanged: (val) => password = val,
                          icon: Icons.lock),
                      _buildTextField(
                          label: "Confirmer le mot de passe",
                          obscure: _obscureConfirmText,
                          onChanged: (val) => confirmPassword = val,
                          icon: Icons.lock,
                          isConfirm: true),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            "S'inscrire",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                const SizedBox(height: 30),
                const Text(
                  "Maison Connectée © 2025",
                  style: TextStyle(color: Colors.white54),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
