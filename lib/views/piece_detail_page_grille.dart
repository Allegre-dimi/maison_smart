import 'dart:async';

import 'package:flutter/material.dart';

import '../models/module.dart';
import '../models/piece.dart';
import '../models/utilisateur.dart';
import '../services/api_client.dart';
import '../services/maison_service.dart';
import '../services/module_service.dart';
import 'clim_page.dart';
import 'compteur_page.dart';
import 'gaz_page.dart';
import 'lumière_page.dart';
import 'prise_page.dart';

class PieceDetailPage extends StatefulWidget {
  final Piece piece;
  final bool isDarkMode;
  final Utilisateur utilisateur;

  const PieceDetailPage({
    Key? key,
    required this.piece,
    required this.isDarkMode,
    required this.utilisateur,
  }) : super(key: key);

  @override
  State<PieceDetailPage> createState() => _PieceDetailPageState();
}

class _PieceDetailPageState extends State<PieceDetailPage> {
  final ModuleService _moduleService = ModuleService();
  final MaisonService _maisonService = MaisonService();

  bool _loading = true;
  bool _hasAccessToPiece = true;
  bool _canAddDevice = false;
  String _role = 'membre';
  List<Module> _modules = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) => _refreshModules());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final houseId = widget.utilisateur.activeHouseId;
    if (houseId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final maison = await _maisonService.getMaison(houseId);
      final isOwner = maison?.ownerId == widget.utilisateur.uid;
      final isAdmin =
          (maison?.adminIds ?? const []).contains(widget.utilisateur.uid);
      _role = isOwner ? 'propriétaire' : (isAdmin ? 'admin' : 'membre');
      _canAddDevice = isOwner || isAdmin;
      _modules = await _moduleService.getModulesByPieceId(widget.piece.id);
    } on ApiException {
      _hasAccessToPiece = false;
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _refreshModules() async {
    try {
      final fresh = await _moduleService.getModulesByPieceId(widget.piece.id);
      if (mounted) setState(() => _modules = fresh);
    } on ApiException {
      // ignore
    }
  }

  bool _canEditModule() => _role == 'propriétaire' || _role == 'admin';

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode ? Colors.black : Colors.grey[50];
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;

    if (_loading) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(title: Text(widget.piece.nom)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (!_hasAccessToPiece) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(title: Text(widget.piece.nom)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text("Accès refusé",
                  style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Vous n'avez pas l'autorisation d'accéder à cette pièce",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(widget.piece.nom),
        actions: [
          if (_canAddDevice)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddDialog(context),
              tooltip: "Ajouter un appareil",
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshModules,
        child: _modules.isEmpty
            ? ListView(children: [
                const SizedBox(height: 120),
                Center(
                  child: Text("Aucun appareil",
                      style: TextStyle(color: textColor)),
                ),
              ])
            : ListView.builder(
                itemCount: _modules.length,
                itemBuilder: (context, index) {
                  final module = _modules[index];
                  final canEdit = _canEditModule();
                  return Card(
                    color: widget.isDarkMode ? Colors.grey[900] : Colors.white,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: Icon(Icons.devices,
                          color: canEdit ? Colors.blue : Colors.grey),
                      title: Text(module.nom,
                          style: TextStyle(
                              fontWeight: canEdit
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                      subtitle: Text(
                          "Type: ${module.djangoType} | État: ${module.etat ? 'ON' : 'OFF'}"),
                      trailing: canEdit
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.orangeAccent),
                                    onPressed: () =>
                                        _showEditDialog(context, module)),
                                IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () =>
                                        _deleteModule(context, module)),
                              ],
                            )
                          : null,
                      onTap: () => _openModule(module),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _openModule(Module module) {
    final pieceName = widget.piece.nom;
    final asMap = {
      'nom': module.nom,
      'type': module.djangoType,
      'pieceId': module.pieceId,
    };
    switch (module.djangoType) {
      case 'compteur':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => CompteurPage(moduleId: module.id)));
        break;
      case 'clim':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClimPage(
              moduleId: module.id,
              moduleData: asMap,
              isDarkMode: widget.isDarkMode,
            ),
          ),
        );
        break;
      case 'eclairage':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => LampeScreen(
                      moduleId: module.id,
                      pieceName: pieceName,
                    )));
        break;
      case 'gaz':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => GazPage(moduleId: module.id)));
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PriseScreen(moduleId: module.id, pieceName: pieceName),
          ),
        );
    }
  }

  Future<void> _showAddDialog(BuildContext context) async {
    if (!_canAddDevice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Vous n'avez pas la permission d'ajouter un appareil"),
            backgroundColor: Colors.redAccent),
      );
      return;
    }
    final TextEditingController nomController = TextEditingController();
    String? selectedType;
    // 'assistant_vocal' n'est pas un appareil ajoutable (c'est le système
    // de commande vocale).
    const types = [
      'prise',
      'climatisation',
      'lampe',
      'gaz',
      'compteur',
    ];
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ajouter un appareil"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomController,
              decoration: const InputDecoration(labelText: "Nom de l'appareil"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Type d'appareil"),
              value: selectedType,
              items: types
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => selectedType = v,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (nomController.text.trim().isEmpty || selectedType == null) {
                return;
              }
              try {
                await _moduleService.addModule(Module(
                  id: '',
                  nom: nomController.text.trim(),
                  type: selectedType!,
                  pieceId: widget.piece.id,
                  houseId: widget.piece.houseId,
                  userId: widget.utilisateur.uid,
                ));
                Navigator.pop(ctx);
                await _refreshModules();
              } on ApiException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erreur : ${e.message}")),
                );
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, Module module) async {
    if (!_canEditModule()) return;
    final TextEditingController nomController =
        TextEditingController(text: module.nom);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Modifier l'appareil"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomController,
              decoration: const InputDecoration(labelText: "Nom de l'appareil"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (nomController.text.trim().isEmpty) return;
              try {
                final updated = await _moduleService.updateModule(
                  module.id,
                  type: module.djangoType,
                  patch: {'nom': nomController.text.trim()},
                );
                if (!mounted) return;
                setState(() {
                  final i = _modules.indexWhere((m) => m.id == module.id);
                  if (i >= 0) _modules[i] = updated;
                });
                Navigator.pop(ctx);
              } on ApiException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erreur : ${e.message}")),
                );
              }
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteModule(BuildContext context, Module module) async {
    if (!_canEditModule()) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Voulez-vous vraiment supprimer cet appareil ?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _moduleService.deleteModule(module.id, type: module.djangoType);
      if (mounted) {
        setState(() => _modules.removeWhere((m) => m.id == module.id));
      }
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.message}")),
      );
    }
  }
}
