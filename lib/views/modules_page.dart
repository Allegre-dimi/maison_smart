import 'dart:async';

import 'package:flutter/material.dart';

import '../models/module.dart';
import '../models/piece.dart';
import '../services/api_client.dart';
import '../services/module_service.dart';
import '../services/piece_service.dart';
import '../services/session_service.dart';

class ModulesPage extends StatefulWidget {
  final bool isDarkMode;

  const ModulesPage({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  State<ModulesPage> createState() => _ModulesPageState();
}

class _ModulesPageState extends State<ModulesPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedType = 'tous';

  final ModuleService _moduleService = ModuleService();
  final PieceService _pieceService = PieceService();

  Future<List<Module>>? _future;
  Map<String, String> _pieceNames = {};
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() => _future = _load());
    });
  }

  Future<List<Module>> _load() async {
    final houseId = SessionService().utilisateur?.activeHouseId;
    if (houseId == null || houseId.isEmpty) return [];
    final pieces = await _pieceService.listPieces(houseId: houseId);
    _pieceNames = {for (final Piece p in pieces) p.id: p.nom};
    final all = await _moduleService.getModulesByMaison(houseId);
    return all;
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  IconData _iconFor(String type) {
    switch (type.toLowerCase()) {
      case 'lampe':
      case 'eclairage':
        return Icons.lightbulb;
      case 'prise':
      case 'compteur':
        return Icons.power;
      case 'climatisation':
      case 'clim':
        return Icons.ac_unit;
      case 'gaz':
        return Icons.sensors;
      case 'assistant_vocal':
        return Icons.record_voice_over;
      default:
        return Icons.devices;
    }
  }

  Future<void> _toggle(Module module, bool newValue) async {
    try {
      final updated = await _moduleService
          .setEtat(module.id, newValue, type: module.djangoType);
      setState(() {
        module.etat = updated.etat;
      });
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.message}")),
      );
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chips = const [
      'tous',
      'prise',
      'lampe',
      'climatisation',
      'gaz',
      'compteur'
    ];
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(title: const Text('Tous les appareils')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Rechercher un appareil…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: chips
                  .map((t) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(t.toUpperCase()),
                          selected: _selectedType == t,
                          onSelected: (_) => setState(() => _selectedType = t),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<Module>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return ListView(
                      children: [
                        const SizedBox(height: 80),
                        Center(child: Text("Erreur : ${snapshot.error}")),
                      ],
                    );
                  }
                  final all = snapshot.data ?? const [];
                  final filtered = all.where((m) {
                    final matchType = _selectedType == 'tous' ||
                        m.djangoType == _selectedType ||
                        (_selectedType == 'prise' && m.djangoType == 'compteur') ||
                        (_selectedType == 'lampe' && m.djangoType == 'eclairage') ||
                        (_selectedType == 'climatisation' && m.djangoType == 'clim');
                    if (!matchType) return false;
                    final q = _searchCtrl.text.trim().toLowerCase();
                    return q.isEmpty || m.nom.toLowerCase().contains(q);
                  }).toList();

                  if (filtered.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text("Aucun appareil")),
                      ],
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final module = filtered[index];
                      final pieceName = _pieceNames[module.pieceId] ?? '';
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Icon(_iconFor(module.djangoType),
                              color: (module.etat && module.isSwitchable)
                                  ? Colors.green
                                  : Colors.grey),
                          title: Text(module.nom,
                              style: TextStyle(color: textColor)),
                          subtitle: pieceName.isEmpty
                              ? null
                              : Text('Pièce : $pieceName',
                                  style: TextStyle(color: textColor)),
                          trailing: module.isSwitchable
                              ? Switch(
                                  value: module.etat,
                                  onChanged: (v) => _toggle(module, v),
                                )
                              : null,
                          onTap: () {},
                        ),
                      );
                    },
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
