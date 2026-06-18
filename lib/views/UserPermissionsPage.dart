import 'package:flutter/material.dart';

import '../models/maison.dart';
import '../models/module.dart';
import '../models/piece.dart';
import '../models/utilisateur.dart';
import '../services/api_client.dart';
import '../services/maison_service.dart';
import '../services/module_service.dart';
import '../services/piece_service.dart';

/// Page de permissions utilisateurs.
///
/// Côté Django, la gestion fine des permissions par pièce/module n'est
/// pas exposée — l'écran affiche la structure et signale que les
/// modifications ne sont pas encore disponibles côté serveur.
class UserPermissionsPage extends StatefulWidget {
  final Utilisateur utilisateur;
  final bool isDarkMode;

  const UserPermissionsPage({
    Key? key,
    required this.utilisateur,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<UserPermissionsPage> createState() => _UserPermissionsPageState();
}

class _UserPermissionsPageState extends State<UserPermissionsPage> {
  Maison? _maison;
  List<Piece> _pieces = [];
  Map<String, List<Module>> _modulesByPiece = {};
  bool isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final houseId = widget.utilisateur.activeHouseId;
    if (houseId == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      _maison = await MaisonService().getMaison(houseId);
      _pieces = await PieceService().listPieces(houseId: houseId);
      _modulesByPiece = {};
      for (final piece in _pieces) {
        _modulesByPiece[piece.id] =
            await ModuleService().getModulesByPieceId(piece.id);
      }
    } on ApiException catch (e) {
      _error = e.message;
    }
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  bool get isCurrentUserOwner =>
      widget.utilisateur.uid == _maison?.ownerId;

  String _roleOf(String uid) {
    if (_maison == null) return 'membre';
    if (_maison!.ownerId == uid) return 'propriétaire';
    if ((_maison!.adminIds ?? const []).contains(uid)) return 'admin';
    return 'membre';
  }

  void _notImplemented() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
          "La gestion fine des permissions n'est pas encore disponible côté serveur."),
    ));
  }

  Widget _buildUserBlock(String uid) {
    final role = _roleOf(uid);
    return ExpansionTile(
      title: Row(
        children: [
          Text(uid),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: role == 'propriétaire'
                  ? Colors.orange[100]
                  : role == 'admin'
                      ? Colors.blue[100]
                      : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              role,
              style: TextStyle(
                color: role == 'propriétaire'
                    ? Colors.orange[800]
                    : role == 'admin'
                        ? Colors.blue[800]
                        : Colors.grey[800],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: role == 'propriétaire'
          ? const Text("Toutes les permissions",
              style: TextStyle(color: Colors.orange))
          : null,
      children: [
        SwitchListTile(
          title: const Text("Peut ajouter un appareil"),
          subtitle:
              const Text("Réservé au propriétaire / admins côté Django"),
          value: role == 'propriétaire' || role == 'admin',
          onChanged: (_) => _notImplemented(),
          secondary: const Icon(Icons.add_circle_outline),
        ),
        const Divider(),
        ..._pieces.map((piece) {
          final pieceAllowed = role != 'membre';
          return ExpansionTile(
            title: Row(
              children: [
                Checkbox(
                  value: pieceAllowed,
                  onChanged: (_) => _notImplemented(),
                ),
                const SizedBox(width: 8),
                Text(piece.nom),
              ],
            ),
            children: _modulesByPiece[piece.id]?.map<Widget>((module) {
                  return SwitchListTile(
                    title: Text(module.nom),
                    value: pieceAllowed,
                    onChanged: pieceAllowed ? (_) => _notImplemented() : null,
                    secondary: Icon(
                      Icons.devices,
                      color: pieceAllowed ? Colors.blue : Colors.grey[300],
                    ),
                  );
                }).toList() ??
                const [],
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (_maison == null) {
      return Center(child: Text(_error ?? "Aucune maison trouvée."));
    }
    final memberIds = <String>{};
    memberIds.add(_maison!.ownerId);
    memberIds.addAll(_maison!.adminIds ?? const []);
    memberIds.addAll(_maison!.members ?? const []);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Permissions utilisateurs"),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (isCurrentUserOwner)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Permissions"),
                    content: const Text(
                      "La gestion granulaire des permissions n'est pas encore "
                      "supportée par le backend Django. Toute modification est "
                      "ignorée pour l'instant.",
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK")),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isCurrentUserOwner)
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.security, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Vous êtes propriétaire. Les permissions affichées sont en lecture seule.",
                        style: TextStyle(color: Colors.green[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          ...memberIds.map((uid) => Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: _buildUserBlock(uid),
              )),
        ],
      ),
    );
  }
}
