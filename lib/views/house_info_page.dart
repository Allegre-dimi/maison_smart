import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/maison.dart';
import '../models/utilisateur.dart';
import '../services/api_client.dart';
import '../services/maison_service.dart';
import '../views/select_house_page.dart';

class HouseInfoPage extends StatefulWidget {
  final Maison maison;
  final Utilisateur utilisateur;

  const HouseInfoPage({
    Key? key,
    required this.maison,
    required this.utilisateur,
  }) : super(key: key);

  @override
  State<HouseInfoPage> createState() => _HouseInfoPageState();
}

class _HouseInfoPageState extends State<HouseInfoPage> {
  late TextEditingController nameController;
  late TextEditingController codeController;
  late TextEditingController adresseController;
  late TextEditingController villeController;
  late TextEditingController paysController;
  late TextEditingController phoneController;
  late Maison currentMaison;

  final MaisonService _service = MaisonService();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    currentMaison = widget.maison;
    _initControllers(widget.maison);
    _refresh();
  }

  void _initControllers(Maison maison) {
    nameController = TextEditingController(text: maison.name);
    codeController = TextEditingController(text: maison.code ?? "");
    adresseController = TextEditingController(text: maison.adresse ?? "");
    villeController = TextEditingController(text: maison.ville ?? "");
    paysController = TextEditingController(text: maison.pays ?? "");
    phoneController = TextEditingController(text: maison.telephone ?? "");
  }

  Future<void> _refresh() async {
    try {
      final m = await _service.getMaison(widget.maison.houseId);
      if (m != null && mounted) {
        setState(() {
          currentMaison = m;
          _initControllers(m);
        });
      }
    } on ApiException {
      // ignore
    }
  }

  Future<void> _updateHouse() async {
    setState(() => _busy = true);
    try {
      final updated = await _service.updateMaison(currentMaison.houseId, {
        'name': nameController.text.trim(),
        'code': codeController.text.trim(),
        'adresse': adresseController.text.trim(),
        'ville': villeController.text.trim(),
        'pays': paysController.text.trim(),
        'telephone': phoneController.text.trim(),
      });
      if (!mounted) return;
      setState(() => currentMaison = updated);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maison mise à jour avec succès ✅")),
      );
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.message}")),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleHouseActivation(bool activate) async {
    final action = activate ? "activer" : "désactiver";
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("${activate ? "Activer" : "Désactiver"} la maison"),
        content: Text(
          activate
              ? "Voulez-vous réactiver cette maison ?\n\n"
                  "Tous les membres pourront à nouveau y accéder."
              : "Voulez-vous désactiver cette maison ?\n\n"
                  "⚠️ Tous les utilisateurs seront déconnectés de cette maison !\n"
                  "Ils ne pourront plus y accéder jusqu'à sa réactivation.",
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              action.capitalize(),
              style: TextStyle(color: activate ? Colors.green : Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final updated = await _service
          .updateMaison(currentMaison.houseId, {'is_active': activate});
      if (!mounted) return;
      setState(() => currentMaison = updated);
      if (!activate) {
        widget.utilisateur.activeHouseId = null;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => SelectHousePage(utilisateur: widget.utilisateur),
          ),
          (route) => false,
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Maison ${activate ? "activée ✅" : "désactivée ❌"}"),
          backgroundColor: activate ? Colors.green : Colors.orange,
        ),
      );
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.message}")),
      );
    }
  }

  void _showEditModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 25,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Modifier la maison",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _inputField("Nom de la maison", nameController),
                _inputField("Code maison", codeController),
                _inputField("Adresse", adresseController),
                _inputField("Ville", villeController),
                _inputField("Pays", paysController),
                _inputField("Téléphone", phoneController),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: _busy ? null : _updateHouse,
                    icon: const Icon(Icons.save),
                    label: Text(
                      _busy ? "Enregistrement..." : "Enregistrer",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maison = currentMaison;
    final isOwner = widget.utilisateur.uid == maison.ownerId;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Informations de la maison"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditModal,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(maison, isOwner),
          const SizedBox(height: 25),
          _sectionTitle("Informations générales"),
          _infoCard(Icons.vpn_key, "Code maison", maison.code ?? "Aucun"),
          _infoCard(
            Icons.calendar_today,
            "Créée le",
            "${maison.createdAt.day}/${maison.createdAt.month}/${maison.createdAt.year}",
          ),
          const SizedBox(height: 25),
          _sectionTitle("Localisation"),
          _infoCard(Icons.location_on, "Adresse", maison.adresse ?? "Non fournie"),
          _infoCard(
              Icons.location_city, "Ville", maison.ville ?? "Non fournie"),
          _infoCard(Icons.flag, "Pays", maison.pays ?? "Non fourni"),
          const SizedBox(height: 25),
          _sectionTitle("Contact"),
          _infoCard(Icons.phone, "Téléphone", maison.telephone ?? "Non fourni"),
          const SizedBox(height: 35),
          if (isOwner)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    maison.isActive ? Colors.red[400] : Colors.green[400],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () => _toggleHouseActivation(!maison.isActive),
              icon: Icon(maison.isActive
                  ? Icons.power_settings_new
                  : Icons.check_circle_outline),
              label: Text(
                maison.isActive ? "Désactiver la maison" : "Activer la maison",
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header(Maison maison, bool isOwner) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: maison.isActive
              ? [Colors.deepPurple, Colors.purpleAccent]
              : [Colors.grey, Colors.grey[400]!],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.home_rounded,
            color: maison.isActive ? Colors.white : Colors.grey[600],
            size: 40,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maison.name,
                  style: GoogleFonts.poppins(
                    color: maison.isActive ? Colors.white : Colors.grey[700],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isOwner
                      ? "👑 Propriétaire"
                      : "👤 ${maison.isActive ? "Membre actif" : "Membre (désactivé)"}",
                  style: GoogleFonts.poppins(
                    color: maison.isActive
                        ? Colors.white.withOpacity(0.9)
                        : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!maison.isActive)
            const Icon(Icons.pause_circle_filled, color: Colors.white, size: 30),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.deepPurple.withOpacity(0.1),
            child: Icon(icon, color: Colors.deepPurple),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
