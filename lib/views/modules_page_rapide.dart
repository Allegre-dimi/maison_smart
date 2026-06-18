import 'dart:async';

import 'package:flutter/material.dart';

import '../models/module.dart';
import '../models/piece.dart';
import '../models/utilisateur.dart';
import '../services/api_client.dart';
import '../services/maison_service.dart';
import '../services/module_service.dart';
import '../services/piece_service.dart';

class ModulesPageRapide extends StatefulWidget {
  final Utilisateur utilisateur;
  final bool isDarkMode;

  const ModulesPageRapide({
    Key? key,
    required this.utilisateur,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<ModulesPageRapide> createState() => _ModulesPageRapideState();
}

class _ModulesPageRapideState extends State<ModulesPageRapide> {
  final TextEditingController _searchCtrl = TextEditingController();
  final PieceService _pieceService = PieceService();
  final ModuleService _moduleService = ModuleService();
  final MaisonService _maisonService = MaisonService();

  bool _loadingPermissions = true;
  bool _isOwnerOrAdmin = false;
  List<Piece> _pieces = [];
  List<Module> _modules = [];

  String _selectedPiece = 'tous';
  String _selectedType = 'tous';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) => _refreshModules());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final houseId = widget.utilisateur.activeHouseId;
    if (houseId == null) return;
    try {
      final maison = await _maisonService.getMaison(houseId);
      _isOwnerOrAdmin = maison?.ownerId == widget.utilisateur.uid ||
          (maison?.adminIds ?? const []).contains(widget.utilisateur.uid);
      _pieces = await _pieceService.listPieces(houseId: houseId);
      _modules = await _moduleService.getModulesByMaison(houseId);
    } on ApiException {
      // ignore
    }
    if (!mounted) return;
    setState(() => _loadingPermissions = false);
  }

  Future<void> _refreshModules() async {
    final houseId = widget.utilisateur.activeHouseId;
    if (houseId == null) return;
    try {
      _modules = await _moduleService.getModulesByMaison(houseId);
      if (mounted) setState(() {});
    } on ApiException {
      // ignore
    }
  }

  Future<void> _toggleAllModules(bool state) async {
    final targets = _filteredModules().where((m) => m.isSwitchable).toList();
    for (final module in targets) {
      try {
        await _moduleService.setEtat(module.id, state, type: module.djangoType);
        module.etat = state;
      } on ApiException {
        // continue
      }
    }
    if (mounted) setState(() {});
  }

  List<Module> _filteredModules() {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _modules.where((m) {
      if (_selectedPiece != 'tous' && m.pieceId != _selectedPiece) return false;
      if (_selectedType != 'tous' && m.djangoType != _selectedType) return false;
      if (q.isEmpty) return true;
      return m.nom.toLowerCase().contains(q);
    }).toList();
  }

  IconData _iconByType(String type) {
    switch (type) {
      case 'compteur':
      case 'prise':
        return Icons.power;
      case 'eclairage':
      case 'lampe':
        return Icons.lightbulb_outline;
      case 'gaz':
        return Icons.local_gas_station;
      case 'clim':
      case 'climatisation':
        return Icons.ac_unit;
      case 'assistant_vocal':
        return Icons.record_voice_over;
      default:
        return Icons.devices_other;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPermissions) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final filtered = _filteredModules();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modules rapides"),
        backgroundColor: Colors.deepPurple,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPiece,
              dropdownColor: Colors.deepPurple,
              iconEnabledColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              items: [
                const DropdownMenuItem(
                  value: 'tous',
                  child: Text("Toutes les pièces"),
                ),
                ..._pieces.map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.nom),
                    )),
              ],
              onChanged: (v) => setState(() => _selectedPiece = v ?? 'tous'),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Rechercher un module...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.power),
                    label: const Text("Tout allumer"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => _toggleAllModules(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.power_off),
                    label: const Text("Tout éteindre"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => _toggleAllModules(false),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshModules,
              child: filtered.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 80),
                      Center(child: Text("Aucun module accessible")),
                    ])
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 12),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final module = filtered[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: Icon(
                              _iconByType(module.djangoType),
                              color: module.etat ? Colors.deepPurple : Colors.grey,
                            ),
                            title: Text(module.nom),
                            subtitle: Text(
                                "État : ${module.etat ? 'ON' : 'OFF'} • Type : ${module.djangoType}"),
                            trailing: module.isSwitchable
                                ? Switch(
                                    value: module.etat,
                                    onChanged: (v) async {
                                      try {
                                        final updated = await _moduleService
                                            .setEtat(module.id, v, type: module.djangoType);
                                        if (mounted) {
                                          setState(() => module.etat = updated.etat);
                                        }
                                      } on ApiException catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Erreur : ${e.message}")),
                                        );
                                      }
                                    },
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
