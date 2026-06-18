import 'package:flutter/material.dart';
import 'create_house_page.dart';
import 'join_house_page.dart';
import 'bienvenue_page.dart';
import '../models/utilisateur.dart';

class CreationOuConnexionMaisonPage extends StatelessWidget {
  final Utilisateur utilisateur;

  const CreationOuConnexionMaisonPage({Key? key, required this.utilisateur}) : super(key: key);

  void _navigateToBienvenue(BuildContext context, String houseId) {
    // Mettre à jour localement la maison active
    utilisateur.activeHouseId = houseId;

    // Naviguer vers BienvenuePage en remplacement
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => BienvenuePage(utilisateur: utilisateur)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Bouton retour
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Bienvenue dans votre maison connectée !",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(
                  Icons.home_filled,
                  size: 100,
                  color: Colors.white70,
                ),
                const SizedBox(height: 40),
                const Text(
                  "Souhaitez-vous créer une maison ou rejoindre une maison existante ?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_home, size: 28),
                  label: const Text(
                    "Créer une maison",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () async {
                    // Aller vers CreateHousePage
                    final houseId = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateHousePage(utilisateur: utilisateur),
                      ),
                    );

                    // Si on a bien un houseId, naviguer vers BienvenuePage
                    if (houseId != null && houseId.isNotEmpty) {
                      _navigateToBienvenue(context, houseId);
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.group, size: 28),
                  label: const Text(
                    "Rejoindre une maison",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () async {
                    // Aller vers JoinHousePage
                    final houseId = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JoinHousePage(utilisateur: utilisateur),
                      ),
                    );

                    // Si on a bien un houseId, naviguer vers BienvenuePage
                    if (houseId != null && houseId.isNotEmpty) {
                      _navigateToBienvenue(context, houseId);
                    }
                  },
                ),
                const Spacer(),
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
