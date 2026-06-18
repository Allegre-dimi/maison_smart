import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/maison.dart';
import '../models/utilisateur.dart';
import '../screens/theme_provider.dart';
import '../services/api_client.dart';
import '../services/maison_service.dart';
import '../services/session_service.dart';
import 'creation_ou_connexion_maison_page.dart';
import 'home_page_3.dart';

class GestionMaisonsPage extends StatefulWidget {
  final Utilisateur utilisateur;

  const GestionMaisonsPage({Key? key, required this.utilisateur}) : super(key: key);

  @override
  State<GestionMaisonsPage> createState() => _GestionMaisonsPageState();
}

class _GestionMaisonsPageState extends State<GestionMaisonsPage> {
  bool isLoading = true;
  List<Maison> maisons = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMaisons();
  }

  Future<void> _loadMaisons() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final list = await MaisonService().listMaisons();
      widget.utilisateur.houseIds = list.map((m) => m.houseId).toList();
      setState(() {
        maisons = list;
        isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        errorMessage = e.message;
        isLoading = false;
      });
    }
  }

  Future<void> _selectMaison(String houseId) async {
    widget.utilisateur.activeHouseId = houseId;
    await SessionService().setActiveHouse(houseId);
    if (!mounted) return;
    final tp = context.read<ThemeProvider>();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage3(
          utilisateur: widget.utilisateur,
          onToggleTheme: tp.toggleTheme,
          isDarkMode: tp.isDarkMode,
        ),
      ),
    );
  }

  void _ouvrirCreationOuRejoindreMaison() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CreationOuConnexionMaisonPage(utilisateur: widget.utilisateur),
      ),
    ).then((_) => _loadMaisons());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes maisons"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text("Erreur : $errorMessage",
                          style: const TextStyle(color: Colors.red)),
                    ),
                  Expanded(
                    child: maisons.isEmpty
                        ? const Center(
                            child: Text(
                              "Vous n'êtes affilié à aucune maison.\nCréez ou rejoignez une maison pour continuer.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            itemCount: maisons.length,
                            itemBuilder: (context, index) {
                              final maison = maisons[index];
                              final isActive = widget.utilisateur.activeHouseId ==
                                  maison.houseId;
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.home,
                                      color: Colors.deepPurple),
                                  title: Text(maison.name,
                                      style: const TextStyle(fontSize: 18)),
                                  subtitle: const Text(
                                    "Cliquez ici pour accéder à cette maison",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  trailing: isActive
                                      ? const Icon(Icons.check,
                                          color: Colors.green)
                                      : null,
                                  onTap: () => _selectMaison(maison.houseId),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Créer ou rejoindre une maison",
                        style: TextStyle(color: Colors.white),
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
                      onPressed: _ouvrirCreationOuRejoindreMaison,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
