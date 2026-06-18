import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/maison.dart';
import '../models/utilisateur.dart';
import '../screens/theme_provider.dart';
import '../services/api_client.dart';
import '../services/maison_service.dart';
import '../services/session_service.dart';
import '../views/home_page_3.dart';
import '../views/house_settings_page.dart';
import '../views/select_house_page.dart';
import 'abonnement_page.dart';
import 'assistance_page.dart';
import 'device_discovery_page.dart';
import 'history_page.dart';
import 'notifications_page.dart';
import 'wifi_configuration.dart';

class ParametragesPage extends StatefulWidget {
  final Utilisateur utilisateur;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const ParametragesPage({
    super.key,
    required this.utilisateur,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<ParametragesPage> createState() => _ParametragesPageState();
}

class _ParametragesPageState extends State<ParametragesPage> {
  Maison? _maison;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final houseId = widget.utilisateur.activeHouseId;
    if (houseId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      _maison = await MaisonService().getMaison(houseId);
    } on ApiException catch (e) {
      _error = e.message;
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  bool _isOwnerOrAdmin(Maison maison) {
    if (maison.ownerId == widget.utilisateur.uid) return true;
    return (maison.adminIds ?? const []).contains(widget.utilisateur.uid);
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context); // ensure rebuild on theme change
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (widget.utilisateur.activeHouseId == null) {
      return Scaffold(
        body: Center(
          child: Text("Aucune maison active.",
              style: GoogleFonts.poppins(fontSize: 18)),
        ),
      );
    }
    final maison = _maison;
    if (maison == null) {
      return Scaffold(
        body: Center(child: Text(_error ?? "Maison introuvable")),
      );
    }
    final isOwnerOrAdmin = _isOwnerOrAdmin(maison);
    final isOwner = maison.ownerId == widget.utilisateur.uid;
    return _buildUI(context, maison, isOwnerOrAdmin, isOwner);
  }

  Widget _buildUI(BuildContext context, Maison maison, bool isOwnerOrAdmin,
      bool isOwner) {
    if (!maison.isActive && !isOwner) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => SelectHousePage(utilisateur: widget.utilisateur),
                ),
              );
            },
          ),
          title: Text("Paramètres",
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pause_circle_filled,
                    size: 80, color: Colors.grey[400]),
                const SizedBox(height: 20),
                Text("Maison désactivée",
                    style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
                const SizedBox(height: 15),
                Text(
                  "Cette maison est désactivée par le propriétaire.\n\n"
                  "Vous ne pouvez pas accéder aux paramètres.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SelectHousePage(utilisateur: widget.utilisateur),
                      ),
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text("Retour aux maisons"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage3(
                  utilisateur: widget.utilisateur,
                  isDarkMode: widget.isDarkMode,
                  onToggleTheme: widget.onToggleTheme,
                ),
              ),
            );
          },
        ),
        title: Text("Paramètres",
            style: GoogleFonts.poppins(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Configuration & gestion",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildSettingCard(
                context,
                icon: Icons.notifications_active,
                color: Colors.deepPurple,
                text: "Notifications",
                page: const NotificationsPage()),
            if (isOwnerOrAdmin)
              _buildSettingCard(
                  context,
                  icon: Icons.credit_card,
                  color: Colors.deepPurple,
                  text: "Abonnement (paiement)",
                  page: const AbonnementPage()),
            if (isOwnerOrAdmin)
              _buildSettingCard(
                  context,
                  icon: Icons.search,
                  color: Colors.deepPurple,
                  text: "Détecter les appareils ",
                  page: const DeviceDiscoveryPage()),
            if (isOwnerOrAdmin)
              _buildSettingCard(
                  context,
                  icon: Icons.wifi,
                  color: Colors.deepPurple,
                  text: "Configuration Wi-Fi",
                  page: WifiConfigurationPage()),
            _buildSettingCard(
                context,
                icon: Icons.support_agent,
                color: Colors.deepPurple,
                text: "Assistance technique",
                page: const AssistancePage()),
            _buildSettingCard(
                context,
                icon: Icons.history,
                color: Colors.deepPurple,
                text: "Historique d'activité",
                page: const HistoryPage()),
            if (isOwnerOrAdmin)
              _buildSettingCard(
                context,
                icon: Icons.house_rounded,
                color: Colors.deepPurple,
                text: "Paramètres de la maison",
                page: HouseSettingsPage(
                  utilisateur: widget.utilisateur,
                  isDarkMode: widget.isDarkMode,
                  onToggleTheme: widget.onToggleTheme,
                ),
              ),
            const SizedBox(height: 20),
            _buildSettingCard(
              context,
              icon: isOwner ? Icons.delete_forever : Icons.exit_to_app,
              color: isOwner ? Colors.red : Colors.orange,
              text: isOwner ? "Supprimer la maison" : "Quitter la maison",
              page: null,
              onTap: () => isOwner
                  ? _showDeleteHouseDialog(maison)
                  : _showQuitHouseDialog(maison),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
    Widget? page,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ??
          () {
            if (page != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => page),
              );
            }
          },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(text,
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showQuitHouseDialog(Maison maison) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quitter la maison"),
        content: const Text(
          "Le retrait d'un membre depuis l'app n'est pas encore supporté côté backend Django. "
          "Contactez le propriétaire pour vous retirer.",
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK")),
        ],
      ),
    );
  }

  void _showDeleteHouseDialog(Maison maison) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("⚠️ Supprimer la maison"),
        content: const Text(
          "Cette action supprime définitivement la maison et toutes ses données. Continuer ?",
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await MaisonService().deleteMaison(maison.houseId);
                widget.utilisateur.houseIds.remove(maison.houseId);
                if (widget.utilisateur.activeHouseId == maison.houseId) {
                  widget.utilisateur.activeHouseId = null;
                  await SessionService().setActiveHouse(null);
                }
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SelectHousePage(utilisateur: widget.utilisateur),
                  ),
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Maison supprimée."),
                  backgroundColor: Colors.red,
                ));
              } on ApiException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Erreur : ${e.message}"),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
