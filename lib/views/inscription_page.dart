import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/auth_controller.dart';
import '../delayed_animations.dart';

class InscriptionPage extends StatefulWidget {
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

  final AuthController _authController = AuthController();

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final error = await _authController.inscrire(
      email.trim(),
      password.trim(),
      'user',
      nom: fullName.trim(),
      username: username.trim(),
    );

    if (!mounted) return;
    setState(() {
      if (error != null) errorMessage = error;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.black, size: 30),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DelayedAnimations(
                delay: 500,
                child: Text(
                  "Créez votre compte",
                  style: GoogleFonts.poppins(
                    color: Colors.blue[600],
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              DelayedAnimations(
                delay: 800,
                child: Text(
                  'Inscrivez-vous pour protéger votre compte.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    DelayedAnimations(
                      delay: 1000,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nom complet',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => fullName = val,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Entrez votre nom complet';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    DelayedAnimations(
                      delay: 1200,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nom d’utilisateur',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => username = val,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Entrez un nom d’utilisateur';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    DelayedAnimations(
                      delay: 1400,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Adresse email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (val) => email = val,
                        validator: (val) {
                          if (val == null ||
                              val.trim().isEmpty ||
                              !val.contains('@')) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    DelayedAnimations(
                      delay: 1600,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureText,
                        onChanged: (val) => password = val,
                        validator: (val) {
                          if (val == null || val.length < 8) {
                            return '8 caractères minimum';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    DelayedAnimations(
                      delay: 1800,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmText
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmText = !_obscureConfirmText;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureConfirmText,
                        onChanged: (val) => confirmPassword = val,
                        validator: (val) {
                          if (val != password) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              DelayedAnimations(
                delay: 2000,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 118, vertical: 10),
                        ),
                        onPressed: register,
                        child: Text(
                          "S'inscrire",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 50),
              DelayedAnimations(
                delay: 2200,
                child: Image.asset(
                  'images/logo.png',
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
