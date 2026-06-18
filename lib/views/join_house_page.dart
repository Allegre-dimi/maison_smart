import 'package:flutter/material.dart';

import '../models/maison.dart';
import '../models/utilisateur.dart';
import '../services/api_client.dart';
import '../services/maison_service.dart';
import '../services/session_service.dart';

class JoinHousePage extends StatefulWidget {
  final Utilisateur utilisateur;

  const JoinHousePage({Key? key, required this.utilisateur}) : super(key: key);

  @override
  _JoinHousePageState createState() => _JoinHousePageState();
}

class _JoinHousePageState extends State<JoinHousePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _houseCodeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _joinHouse() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final Maison maison = await MaisonService()
          .acceptInvitation(_houseCodeController.text.trim());

      widget.utilisateur.houseIds.add(maison.houseId);
      widget.utilisateur.activeHouseId = maison.houseId;
      await SessionService().setActiveHouse(maison.houseId);

      if (!mounted) return;
      Navigator.pop(context, maison.houseId);
    } on ApiException catch (e) {
      _showMessage(
        e.statusCode == 404
            ? "Code d'invitation introuvable ou expiré."
            : "Erreur : ${e.message}",
        isError: true,
      );
    } catch (e) {
      _showMessage("Erreur : $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 10),
                const Icon(Icons.group, size: 80, color: Colors.white70),
                const SizedBox(height: 20),
                const Text(
                  "Rejoignez une maison existante",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _houseCodeController,
                    decoration: InputDecoration(
                      labelText: "Code de la maison",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon:
                          const Icon(Icons.home_work, color: Colors.deepPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Entrez un code"
                        : null,
                  ),
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _joinHouse,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            "Rejoindre",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
