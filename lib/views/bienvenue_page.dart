// bienvenue_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ndako/views/home_page_3.dart';
import 'package:provider/provider.dart';
import '../screens/theme_provider.dart';
import '../delayed_animations.dart';
import '../models/utilisateur.dart';

class BienvenuePage extends StatelessWidget {
  final Utilisateur utilisateur;

  const BienvenuePage({Key? key, required this.utilisateur}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône
                DelayedAnimations(
                  delay: 500,
                  child: Icon(
                    Icons.thumb_up,
                    size: screenWidth < 360 ? 80 : 100,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                // Titre
                DelayedAnimations(
                  delay: 1000,
                  child: Text(
                    "Bienvenue 🎉",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth < 360 ? 22 : 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Message
                DelayedAnimations(
                  delay: 1500,
                  child: Text(
                    "Merci ${utilisateur.displayName ?? ''} d'avoir installé notre application et de nous faire confiance. Nous espérons que vous apprécierez l'expérience !",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth < 360 ? 14 : 16,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Bouton Commencer
                DelayedAnimations(
                  delay: 2000,
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage3(
                              onToggleTheme: () => themeProvider.toggleTheme(),
                              isDarkMode: themeProvider.isDarkMode,
                              utilisateur: utilisateur,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        "Commencer",
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth < 360 ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Footer
                Text(
                  "Maison Connectée © 2025",
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
