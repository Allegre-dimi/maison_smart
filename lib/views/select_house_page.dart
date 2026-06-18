import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/maison.dart';
import '../models/utilisateur.dart';
import '../screens/theme_provider.dart';
import '../services/api_client.dart';
import '../services/maison_service.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import '../views/create_house_page.dart';
import '../views/home_page_3.dart';
import '../views/join_house_page.dart';

class SelectHousePage extends StatefulWidget {
  final Utilisateur utilisateur;

  const SelectHousePage({Key? key, required this.utilisateur}) : super(key: key);

  @override
  State<SelectHousePage> createState() => _SelectHousePageState();
}

class _SelectHousePageState extends State<SelectHousePage> {
  final MaisonService _service = MaisonService();
  late Future<List<Maison>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Maison>> _load() async {
    final maisons = await _service.listMaisons();
    widget.utilisateur.houseIds = maisons.map((m) => m.houseId).toList();
    return maisons;
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _activateAndOpen(Maison maison) async {
    widget.utilisateur.activeHouseId = maison.houseId;
    await SessionService().setActiveHouse(maison.houseId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes maisons"),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: "Rejoindre une maison",
            icon: const Icon(Icons.qr_code_2_rounded),
            onPressed: _openJoinHouse,
          ),
          IconButton(
            tooltip: "Créer une maison",
            icon: const Icon(Icons.add_home_rounded),
            onPressed: _openCreateHouse,
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openJoinHouse,
        icon: const Icon(Icons.group_add_rounded),
        label: const Text("Rejoindre"),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Maison>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              final err = snapshot.error;
              final msg = err is ApiException ? err.message : err.toString();
              return ListView(
                children: [
                  const SizedBox(height: 60),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.cloud_off,
                              size: 60, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            "Impossible de charger les maisons :\n$msg",
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Réessayer"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            final maisons = snapshot.data ?? const [];
            if (maisons.isEmpty) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentPrimary
                                .withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.home_rounded,
                          color: Colors.white, size: 56),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    "Aucune maison",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Créez votre propre maison ou rejoignez-en une via un code d'invitation.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _openCreateHouse,
                    icon: const Icon(Icons.add_home_rounded),
                    label: const Text("Créer une maison"),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _openJoinHouse,
                    icon: const Icon(Icons.group_add_rounded),
                    label: const Text("Rejoindre via un code"),
                  ),
                ],
              );
            }

            // Si l'utilisateur n'a qu'une seule maison active, l'ouvrir directement.
            if (maisons.length == 1 && maisons.first.isActive) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _activateAndOpen(maisons.first);
              });
              return const Center(child: CircularProgressIndicator());
            }

            final active =
                maisons.where((m) => m.isActive).toList(growable: false);
            final inactive =
                maisons.where((m) => !m.isActive).toList(growable: false);

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (active.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Maisons actives",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                  ...active.map((m) => _houseCard(m, true)),
                ],
                if (inactive.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Maisons désactivées",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                  ...inactive.map((m) => _houseCard(m, false)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _houseCard(Maison maison, bool isActive) {
    final isOwner = widget.utilisateur.uid == maison.ownerId;
    return Card(
      elevation: isActive ? 3 : 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: !isActive ? Colors.grey[100] : Colors.white,
      child: ListTile(
        leading: Icon(
          Icons.home,
          color: isActive ? Colors.deepPurple : Colors.grey,
        ),
        title: Text(
          maison.name,
          style: TextStyle(
            fontSize: 18,
            color: !isActive ? Colors.grey[600] : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ID : ${_shortId(maison.houseId)}"),
            if (!isActive)
              Text(
                isOwner
                    ? "Désactivée — Appuyez pour réactiver"
                    : "🚫 Maison désactivée",
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: isActive
            ? const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.deepPurple)
            : isOwner
                ? const Icon(Icons.settings, color: Colors.orange)
                : const Icon(Icons.block, color: Colors.red),
        onTap: () async {
          if (!isActive) {
            if (isOwner) {
              await _reactivateHouse(maison);
            } else {
              _showHouseDisabledDialog(maison);
            }
            return;
          }
          await _activateAndOpen(maison);
        },
        onLongPress:
            !isActive ? () => _showHouseOptionsDialog(maison, isOwner) : null,
      ),
    );
  }

  Future<void> _openJoinHouse() async {
    final houseId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => JoinHousePage(utilisateur: widget.utilisateur),
      ),
    );
    if (!mounted) return;
    if (houseId != null && houseId.isNotEmpty) {
      _refresh();
    }
  }

  Future<void> _openCreateHouse() async {
    final houseId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateHousePage(utilisateur: widget.utilisateur),
      ),
    );
    if (!mounted) return;
    if (houseId != null && houseId.isNotEmpty) {
      _refresh();
    }
  }

  String _shortId(String id) =>
      id.length <= 8 ? id : '${id.substring(0, 8)}…';

  Future<void> _reactivateHouse(Maison maison) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Réactiver la maison"),
        content: const Text(
          "Voulez-vous réactiver cette maison ?\n\n"
          "Tous les membres pourront à nouveau y accéder.",
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Réactiver",
                  style: TextStyle(color: Colors.green))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _service.updateMaison(maison.houseId, {'is_active': true});
      await _activateAndOpen(maison);
    } on ApiException catch (e) {
      _showSnack("Erreur : ${e.message}", isError: true);
    }
  }

  void _showHouseDisabledDialog(Maison maison) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.block, color: Colors.red),
            SizedBox(width: 10),
            Text("Accès refusé"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Maison: ${maison.name}",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 15),
            const Text(
              "Cette maison est actuellement désactivée par le propriétaire.\n\n"
              "Vous ne pouvez pas y accéder pour le moment.\n\n"
              "Contactez le propriétaire pour demander sa réactivation.",
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer")),
        ],
      ),
    );
  }

  Future<void> _showHouseOptionsDialog(Maison maison, bool isOwner) async {
    final action = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("${maison.name} - Options"),
        content: Text(isOwner
            ? "Vous êtes le propriétaire de cette maison désactivée."
            : "Cette maison est désactivée."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: const Text("Fermer")),
          if (isOwner)
            TextButton(
                onPressed: () => Navigator.pop(context, 'reactivate'),
                child: const Text("Réactiver",
                    style: TextStyle(color: Colors.green))),
          TextButton(
            onPressed: () => Navigator.pop(context, 'remove'),
            child: Text(isOwner ? "Supprimer" : "Retirer",
                style: TextStyle(color: isOwner ? Colors.red : Colors.orange)),
          ),
        ],
      ),
    );
    switch (action) {
      case 'reactivate':
        await _reactivateHouse(maison);
        break;
      case 'remove':
        if (isOwner) {
          await _showDeleteHouseDialog(maison);
        } else {
          _showSnack(
              "Pour quitter une maison sans en être propriétaire, contactez l'admin.",
              isError: true);
        }
        break;
    }
  }

  Future<void> _showDeleteHouseDialog(Maison maison) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("⚠️ Supprimer définitivement"),
        content: const Text(
          "Vous êtes le propriétaire !\n\n"
          "Cette action supprimera COMPLÈTEMENT la maison :\n"
          "• Tous les appareils\n• Toutes les pièces\n• Tout l'historique\n\n"
          "Cette action est irréversible !",
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Supprimer définitivement",
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _service.deleteMaison(maison.houseId);
      _showSnack("Maison supprimée.");
      _refresh();
    } on ApiException catch (e) {
      _showSnack("Erreur : ${e.message}", isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ));
  }
}
