import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../models/maison.dart';
import '../models/utilisateur.dart';
import '../services/api_client.dart';
import '../services/maison_service.dart';
import 'ManageUsersPage.dart';
import 'UserPermissionsPage.dart';
import 'house_info_page.dart';

class HouseSettingsPage extends StatefulWidget {
  final Utilisateur utilisateur;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HouseSettingsPage({
    Key? key,
    required this.utilisateur,
    required this.isDarkMode,
    required this.onToggleTheme,
  }) : super(key: key);

  @override
  State<HouseSettingsPage> createState() => _HouseSettingsPageState();
}

class _HouseSettingsPageState extends State<HouseSettingsPage> {
  Maison? maison;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHouse();
  }

  Future<void> _loadHouse() async {
    final houseId = widget.utilisateur.activeHouseId;
    if (houseId == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      maison = await MaisonService().getMaison(houseId);
    } on ApiException {
      maison = null;
    }
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (maison == null) return const Center(child: Text("Aucune maison trouvée."));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres de la maison"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.home, size: 40, color: Colors.deepPurple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      maison!.name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      Share.share(
                        "Rejoignez ma maison NDÀKO !\nCode : ${maison!.code}",
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSettingButton(
            icon: Icons.info_outline,
            title: "Informations de la maison",
            subtitle: "Adresse • WiFi • Description • Propriétaire",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HouseInfoPage(
                    maison: maison!,
                    utilisateur: widget.utilisateur,
                  ),
                ),
              );
            },
          ),
          _buildSettingButton(
            icon: Icons.group,
            title: "Gérer les utilisateurs",
            subtitle: "Admins, membres…",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManageUsersPage(utilisateur: widget.utilisateur),
                ),
              );
            },
          ),
          _buildSettingButton(
            icon: Icons.lock_outline,
            title: "Permissions par utilisateur",
            subtitle: "Contrôler les accès",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserPermissionsPage(
                    utilisateur: widget.utilisateur,
                    isDarkMode: widget.isDarkMode,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
