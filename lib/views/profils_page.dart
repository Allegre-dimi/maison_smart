import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';

class ProfilsPage extends StatefulWidget {
  const ProfilsPage({Key? key}) : super(key: key);

  @override
  State<ProfilsPage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilsPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  String username = "Utilisateur";
  String email = "—";
  String phone = "Non renseigné";
  String address = "Non renseignée";
  String? profileImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final me = await AuthService().me();
      setState(() {
        username = me.username ?? me.fullName ?? "Utilisateur";
        email = me.email;
        phone = me.phoneNumber ?? "Non renseigné";
        // l'adresse n'est pas renvoyée par le backend côté user — placeholder
        isLoading = false;
      });
    } on ApiException catch (e) {
      debugPrint("Erreur récupération utilisateur: ${e.message}");
      setState(() => isLoading = false);
    } catch (e) {
      debugPrint("Erreur récupération utilisateur: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
          source: ImageSource.gallery, maxWidth: 800);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Erreur pick image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur sélection image : $e")));
    }
  }

  Future<void> _signOut() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _showEditProfileModal(BuildContext context) {
    final TextEditingController nameController =
        TextEditingController(text: username);
    final TextEditingController phoneController = TextEditingController(
        text: phone == "Non renseigné" ? "" : phone);
    final TextEditingController addressController = TextEditingController(
        text: address == "Non renseignée" ? "" : address);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Modifier le profil",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Nom d'utilisateur",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Téléphone",
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: "Adresse",
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text(
                        "Enregistrer (local)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A11CB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          username = nameController.text.trim().isEmpty
                              ? "Utilisateur"
                              : nameController.text.trim();
                          phone = phoneController.text.trim().isEmpty
                              ? "Non renseigné"
                              : phoneController.text.trim();
                          address = addressController.text.trim().isEmpty
                              ? "Non renseignée"
                              : addressController.text.trim();
                        });
                        // miroir local — le backend Django n'expose pas
                        // encore d'endpoint PATCH user pour ces champs.
                        SessionService().utilisateur?.username = username;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                "Profil mis à jour localement (sync à venir).")));
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _askPasswordReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Réinitialiser le mot de passe"),
        content: const Text(
            "La réinitialisation du mot de passe n'est pas encore disponible sur le backend Django."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("OK")),
        ],
      ),
    );
    if (confirm == true) return;
  }

  Widget _buildProfileButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white),
                children: [
                  TextSpan(
                      text: "$label: ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(const Color(0xFF6A11CB)))),
      );
    }

    ImageProvider imageProvider;
    if (_imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    } else if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(profileImageUrl!);
    } else {
      imageProvider = const AssetImage('images/default_avatar.png');
    }

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 6),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: imageProvider,
                      backgroundColor: Colors.white24,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(20),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child:
                              Icon(Icons.camera_alt, color: Colors.deepPurple),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(username,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 6),
                Text(email, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 20),
                _buildProfileButton(
                    icon: Icons.edit,
                    label: "Modifier le profil",
                    onPressed: () => _showEditProfileModal(context)),
                const SizedBox(height: 14),
                _buildProfileButton(
                    icon: FontAwesomeIcons.lock,
                    label: "Changer le mot de passe",
                    onPressed: _askPasswordReset),
                const SizedBox(height: 14),
                _buildProfileButton(
                    icon: FontAwesomeIcons.rightFromBracket,
                    label: "Déconnexion",
                    onPressed: _signOut),
                const SizedBox(height: 26),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text("Informations personnelles",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.person, "Nom d'utilisateur", username),
                      _buildInfoRow(Icons.email, "Email", email),
                      _buildInfoRow(Icons.phone, "Téléphone", phone),
                      _buildInfoRow(Icons.location_on, "Adresse", address),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text("Maison Connectée © 2025",
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
