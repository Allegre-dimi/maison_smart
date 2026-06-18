import 'package:flutter/material.dart';

class HomePage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Maison Connectée",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Action notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Aller au profil utilisateur
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION : BIENVENUE
            Text(
              "Bienvenue, Rex 👋",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Contrôlez et surveillez votre maison en toute simplicité.",
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 20),

            // SECTION : ÉTAT GLOBAL MAISON
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statusItem(Icons.thermostat, "Température", "22°C"),
                    _statusItem(Icons.water_drop, "Humidité", "48%"),
                    _statusItem(Icons.shield, "Sécurité", "Activée"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // SECTION : CONTROLES RAPIDES
            Text(
              "Contrôles rapides",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _controlCard(Icons.lightbulb, "Lumières"),
                _controlCard(Icons.lock, "Portes"),
                _controlCard(Icons.ac_unit, "Climatisation"),
                _controlCard(Icons.local_fire_department, "Gaz"),
              ],
            ),
            SizedBox(height: 20),

            // SECTION : DERNIÈRES ALERTES
            Text(
              "Dernières alertes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            _alertCard("Fuite de gaz détectée", "Aujourd'hui - 14:32"),
            _alertCard("Porte principale ouverte", "Hier - 18:12"),
          ],
        ),
      ),
    );
  }

  Widget _statusItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.teal),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 14)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _controlCard(IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        // Action pour activer/désactiver l'appareil
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.teal),
            SizedBox(height: 10),
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _alertCard(String message, String time) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.warning, color: Colors.red),
        title: Text(message),
        subtitle: Text(time),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          // Voir détails alerte
        },
      ),
    );
  }
}
