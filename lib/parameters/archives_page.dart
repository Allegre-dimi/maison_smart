import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Archives des paiements.
///
/// Côté Django, l'app `payments` ne renvoie pas (encore) d'historique
/// public — cette page sert de placeholder en attendant l'endpoint.
class ArchivesPage extends StatelessWidget {
  final String userId;

  const ArchivesPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Archives des paiements",
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inventory_2_outlined,
                  size: 80, color: Colors.deepPurple),
              const SizedBox(height: 20),
              Text(
                "Les archives seront disponibles\nune fois l'endpoint paiements activé.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
