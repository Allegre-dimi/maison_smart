import 'package:flutter/material.dart';

import '../models/maison.dart';
import '../models/utilisateur.dart';
import '../services/api_client.dart';
import '../services/maison_service.dart';

/// Gestion des utilisateurs d'une maison.
///
/// Côté Django, les opérations admin (toggle admin / remove member) ne sont
/// pas encore exposées via une API publique ; l'écran affiche la liste des
/// membres avec leurs rôles et signale les actions non disponibles.
class ManageUsersPage extends StatefulWidget {
  final Utilisateur utilisateur;

  const ManageUsersPage({Key? key, required this.utilisateur}) : super(key: key);

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  Maison? _maison;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHouse();
  }

  Future<void> _loadHouse() async {
    final houseId = widget.utilisateur.activeHouseId;
    if (houseId == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      _maison = await MaisonService().getMaison(houseId);
    } on ApiException {
      _maison = null;
    }
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> _notImplemented(String action) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("$action n'est pas encore disponible côté serveur."),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    final maison = _maison;
    if (maison == null) {
      return const Center(child: Text("Aucune maison trouvée."));
    }

    final ownerId = maison.ownerId;
    final adminIds = maison.adminIds ?? const [];
    final memberIds = maison.members ?? const [];

    final admins =
        memberIds.where((id) => adminIds.contains(id) && id != ownerId).toList();
    final members =
        memberIds.where((id) => !adminIds.contains(id) && id != ownerId).toList();

    Widget buildMemberTile(String uid, bool isAdmin) {
      final isOwner = uid == ownerId;
      return Card(
        child: ListTile(
          leading: CircleAvatar(
              child: Text(uid.isNotEmpty ? uid[0].toUpperCase() : '?')),
          title: Text(uid),
          subtitle: Text(isOwner
              ? "Propriétaire"
              : isAdmin
                  ? "Admin"
                  : "Membre"),
          trailing: widget.utilisateur.uid == ownerId && !isOwner
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(isAdmin ? Icons.star : Icons.star_border,
                          color: Colors.orange),
                      onPressed: () => _notImplemented("La modification d'admin"),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _notImplemented("La suppression de membre"),
                    ),
                  ],
                )
              : null,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des utilisateurs"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildMemberTile(ownerId, true),
          const Divider(),
          if (admins.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text("Admins",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ...admins.map((id) => buildMemberTile(id, true)),
          const Divider(),
          if (members.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text("Membres",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ...members.map((id) => buildMemberTile(id, false)),
        ],
      ),
    );
  }
}
