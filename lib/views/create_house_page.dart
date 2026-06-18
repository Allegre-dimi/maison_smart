import 'dart:math';

import 'package:flutter/material.dart';

import '../models/utilisateur.dart';
import '../services/api_client.dart';
import '../services/maison_service.dart';
import '../services/session_service.dart';

class CreateHousePage extends StatefulWidget {
  final Utilisateur utilisateur;

  const CreateHousePage({Key? key, required this.utilisateur}) : super(key: key);

  @override
  _CreateHousePageState createState() => _CreateHousePageState();
}

class _CreateHousePageState extends State<CreateHousePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _houseNameController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  String? _selectedPays;
  bool _isLoading = false;

  final List<String> _paysList = [
    "Congo", "France", "Belgique", "Suisse", "Canada",
    "États-Unis", "RDC", "Allemagne", "Italie", "Espagne",
    "Maroc", "Tunisie", "Sénégal", "Mali", "Autre"
  ];

  String generateHouseCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _createHouse() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final maison = await MaisonService().createMaison(
        name: _houseNameController.text.trim(),
        adresse: _adresseController.text.trim(),
        ville: _villeController.text.trim(),
        pays: _selectedPays ?? '',
        telephone: _telephoneController.text.trim(),
        code: generateHouseCode(),
      );

      widget.utilisateur.houseIds.add(maison.houseId);
      if (widget.utilisateur.activeHouseId == null) {
        widget.utilisateur.activeHouseId = maison.houseId;
        await SessionService().setActiveHouse(maison.houseId);
      }

      if (!mounted) return;
      Navigator.pop(context, maison.houseId);
    } on ApiException catch (e) {
      String message = e.message;
      final body = e.body;
      if (body is Map<String, dynamic>) {
        if (body['name'] is List && (body['name'] as List).isNotEmpty) {
          message = (body['name'] as List).first.toString();
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $message"), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: icon != null ? Icon(icon, color: Colors.deepPurple) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) =>
            value == null || value.trim().isEmpty ? "Ce champ est requis" : null,
      ),
    );
  }

  Widget _buildDropdownPays() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedPays,
        decoration: InputDecoration(
          labelText: "Pays",
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.public, color: Colors.deepPurple),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        items: _paysList
            .map((pays) => DropdownMenuItem(value: pays, child: Text(pays)))
            .toList(),
        onChanged: (value) => setState(() => _selectedPays = value),
        validator: (value) =>
            value == null || value.isEmpty ? "Veuillez choisir un pays" : null,
      ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 10),
                const Icon(Icons.home_filled, size: 80, color: Colors.white70),
                const SizedBox(height: 20),
                const Text(
                  "Créez votre maison connectée",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                          controller: _houseNameController,
                          label: "Nom de la maison",
                          icon: Icons.home),
                      _buildTextField(
                          controller: _adresseController,
                          label: "Adresse",
                          icon: Icons.location_on),
                      _buildTextField(
                          controller: _villeController,
                          label: "Ville",
                          icon: Icons.location_city),
                      _buildDropdownPays(),
                      _buildTextField(
                          controller: _telephoneController,
                          label: "Téléphone",
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _createHouse,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  "Créer ma maison",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
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
