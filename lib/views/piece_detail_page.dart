import 'dart:async';

import 'package:flutter/material.dart';

import '../models/module.dart';
import '../models/piece.dart';
import '../services/api_client.dart';
import '../services/module_service.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import '../views/module_detail_page.dart';
import '../widgets/device_visual.dart';

class PieceDetailPage extends StatefulWidget {
  final Piece piece;

  const PieceDetailPage({Key? key, required this.piece}) : super(key: key);

  @override
  State<PieceDetailPage> createState() => _PieceDetailPageState();
}

class _PieceDetailPageState extends State<PieceDetailPage> {
  final ModuleService _moduleService = ModuleService();
  Future<List<Module>>? _future;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() => _future = _load());
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<List<Module>> _load() =>
      _moduleService.getModulesByPieceId(widget.piece.id);

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _addModuleDialog(BuildContext context) async {
    String nom = '';
    String type = 'prise';
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter un appareil"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: "Description de l'appareil"),
                  onChanged: (val) => nom = val.trim(),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Nom requis" : null,
                ),
                DropdownButtonFormField<String>(
                  value: type,
                  // 'assistant_vocal' volontairement absent : ce n'est pas un
                  // appareil ajoutable mais le système de commande vocale.
                  items: const <String>[
                    'gaz',
                    'climatisation',
                    'prise',
                    'lampe',
                    'compteur',
                  ]
                      .map((t) => DropdownMenuItem(
                          value: t, child: Text(t.toUpperCase())))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) type = val;
                  },
                  decoration:
                      const InputDecoration(labelText: "Type d'appareil"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler")),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                if (type == 'gaz' &&
                    widget.piece.type.toLowerCase() != 'cuisine') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            "Le module Gaz ne peut être ajouté qu'à la cuisine.")),
                  );
                  return;
                }

                try {
                  final session = SessionService().utilisateur;
                  await _moduleService.addModule(Module(
                    id: '',
                    nom: nom,
                    type: type,
                    pieceId: widget.piece.id,
                    houseId: widget.piece.houseId,
                    userId: session?.uid ?? '',
                  ));
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Module ajouté avec succès !")),
                  );
                  await _refresh();
                } on ApiException catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erreur : ${e.message}")),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erreur lors de l'ajout : $e")),
                  );
                }
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleModule(Module module) async {
    if (!module.isSwitchable) return;
    try {
      final updated = await _moduleService.setEtat(
          module.id, !module.etat, type: module.djangoType);
      setState(() => module.etat = updated.etat);
    } on ApiException catch (e) {
      debugPrint("Erreur toggle module: ${e.message}");
    }
  }

  Future<void> _deleteModule(Module module) async {
    try {
      await _moduleService.deleteModule(module.id, type: module.djangoType);
      await _refresh();
    } on ApiException catch (e) {
      debugPrint("Erreur suppression module: ${e.message}");
    }
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
      case 'assistant_vocal':
        return Icons.record_voice_over;
      case 'gaz':
      default:
        return Icons.sensors;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.piece.nom),
        actions: [
          IconButton(
            tooltip: "Actualiser",
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refresh,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Module>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ErrorState(
                message: "Erreur de chargement : ${snapshot.error}",
                onRetry: _refresh,
              );
            }
            final modules = snapshot.data ?? const [];
            if (modules.isEmpty) {
              return _EmptyState(onAdd: () => _addModuleDialog(context));
            }
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${modules.length} appareil${modules.length > 1 ? 's' : ''}",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.65),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        Text(
                          "${modules.where((m) => m.etat && m.isSwitchable).length} actif(s)",
                          style: TextStyle(
                            color: AppColors.stateSuccess,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 100),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _DeviceCard(
                        module: modules[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ModuleDetailPage(
                              pieceId: widget.piece.id,
                              moduleId: modules[i].id,
                            ),
                          ),
                        ),
                        onToggle: () => _toggleModule(modules[i]),
                        onLongPress: () => _confirmDelete(modules[i]),
                      ),
                      childCount: modules.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addModuleDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text("Ajouter"),
      ),
    );
  }

  Future<void> _confirmDelete(Module module) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Supprimer ${module.nom} ?"),
        content: const Text("Cet appareil sera retiré de la pièce."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler")),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.stateDanger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
    if (ok == true) await _deleteModule(module);
  }
}

/// Carte premium pour un module : icône badge, nom, état, switch.
/// Effet glow accent quand le module est actif.
class _DeviceCard extends StatelessWidget {
  final Module module;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;

  const _DeviceCard({
    required this.module,
    required this.onTap,
    required this.onToggle,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.forDeviceType(module.djangoType);
    final isOn = module.etat && module.isSwitchable;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: isOn
            ? LinearGradient(
                colors: [
                  accent.withValues(alpha: isDark ? 0.20 : 0.10),
                  cardColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isOn ? null : cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isOn
                ? accent.withValues(alpha: 0.6)
                : borderColor),
        boxShadow: isOn
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: isDark ? 0.35 : 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DeviceIconBadge(
                      type: module.djangoType,
                      active: isOn,
                      size: 42,
                    ),
                    if (module.isSwitchable)
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: module.etat,
                          onChanged: (_) => onToggle(),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${module.niveau ?? '--'}",
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  module.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  module.isSwitchable
                      ? (isOn ? "Allumé" : "Éteint")
                      : (module.type),
                  style: TextStyle(
                    fontSize: 12,
                    color: isOn
                        ? accent
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                    fontWeight: FontWeight.w500,
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

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      children: [
        const SizedBox(height: 60),
        Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPrimary.withValues(alpha: 0.32),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.devices_other_rounded,
                color: Colors.white, size: 44),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          "Aucun appareil",
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          "Ajoute ta première lampe, climatiseur ou compteur dans cette pièce.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text("Ajouter un appareil"),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.cloud_off_rounded,
            size: 60, color: AppColors.stateDanger),
        const SizedBox(height: 16),
        Text(message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Réessayer"),
          ),
        ),
      ],
    );
  }
}
