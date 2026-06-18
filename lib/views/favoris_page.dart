import 'package:flutter/material.dart';

import '../models/module.dart';
import '../models/utilisateur.dart';
import '../services/module_service.dart';
import 'clim_page.dart';
import 'compteur_page.dart';
import 'gaz_page.dart';
import 'lumière_page.dart';
import 'prise_page.dart';

/// Page favoris. Le backend Django ne fournit pas (encore) de notion de favoris,
/// on affiche tous les modules marqués `isFavoris == true`.
class FavorisPage extends StatefulWidget {
  final Utilisateur utilisateur;
  final bool isDarkMode;

  const FavorisPage({
    Key? key,
    required this.utilisateur,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<FavorisPage> createState() => _FavorisPageState();
}

class _FavorisPageState extends State<FavorisPage> {
  final ModuleService _service = ModuleService();
  Future<List<Module>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Module>> _load() async {
    final houseId = widget.utilisateur.activeHouseId;
    if (houseId == null) return [];
    final all = await _service.getModulesByMaison(houseId);
    return all.where((m) => m.isFavoris == true).toList();
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode ? Colors.black : Colors.grey[50];
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;

    if (widget.utilisateur.activeHouseId == null) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(title: const Text("Favoris")),
        body: Center(
          child: Text("Vous n'avez pas de maison active",
              style: TextStyle(color: textColor)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(title: const Text("Favoris")),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Module>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final favs = snapshot.data ?? const [];
            if (favs.isEmpty) {
              return ListView(children: [
                const SizedBox(height: 80),
                Center(
                  child: Text("Aucun favori pour le moment",
                      style: TextStyle(color: textColor)),
                ),
              ]);
            }
            return ListView.builder(
              itemCount: favs.length,
              itemBuilder: (context, index) {
                final module = favs[index];
                return Card(
                  color: widget.isDarkMode ? Colors.grey[900] : Colors.white,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: Text(module.nom,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Type: ${module.djangoType}"),
                    onTap: () => _openModule(module),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _openModule(Module module) {
    final asMap = {
      'nom': module.nom,
      'type': module.djangoType,
      'pieceId': module.pieceId,
    };
    switch (module.djangoType) {
      case 'compteur':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CompteurPage(moduleId: module.id)));
        break;
      case 'clim':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ClimPage(
                    moduleId: module.id,
                    moduleData: asMap,
                    isDarkMode: widget.isDarkMode)));
        break;
      case 'eclairage':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => LampeScreen(
                    moduleId: module.id, pieceName: module.pieceId)));
        break;
      case 'gaz':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => GazPage(moduleId: module.id)));
        break;
      default:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => PriseScreen(
                    moduleId: module.id, pieceName: module.pieceId)));
    }
  }
}
