import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../models/module.dart';
import '../services/api_client.dart';
import '../services/module_service.dart';
import '../widgets/alert_box.dart';

class ModuleDetailPage extends StatefulWidget {
  final String pieceId;
  final String moduleId;

  const ModuleDetailPage({
    Key? key,
    required this.pieceId,
    required this.moduleId,
  }) : super(key: key);

  @override
  State<ModuleDetailPage> createState() => _ModuleDetailPageState();
}

class _ModuleDetailPageState extends State<ModuleDetailPage> {
  Module? _module;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refresh();
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 10), (_) => _refresh());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    // Le type étant inconnu a priori (différents endpoints), on essaie les
    // collections une par une.
    for (final t in const [
      'compteur',
      'gaz',
      'clim',
      'eclairage',
      'assistant_vocal',
    ]) {
      try {
        final m =
            await ModuleService().getModule(widget.moduleId, type: t);
        if (m != null) {
          if (mounted) setState(() => _module = m);
          return;
        }
      } on ApiException {
        // try next
      }
    }
    if (mounted) setState(() => _error = "Appareil introuvable.");
  }

  Future<void> _toggle() async {
    final m = _module;
    if (m == null) return;
    try {
      final updated =
          await ModuleService().setEtat(m.id, !m.etat, type: m.djangoType);
      if (mounted) setState(() => _module = updated);
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${e.message}")));
    }
  }

  Future<void> _setIntensite(int value) async {
    final m = _module;
    if (m == null) return;
    try {
      final updated = await ModuleService().commande(
        m.id,
        action: 'set',
        type: m.djangoType,
        payload: {'intensite': value},
      );
      if (mounted) setState(() => _module = updated);
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${e.message}")));
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'eclairage':
      case 'lampe':
        return Icons.lightbulb_outline;
      case 'compteur':
      case 'prise':
        return Icons.power_outlined;
      case 'clim':
      case 'climatisation':
        return Icons.ac_unit;
      case 'gaz':
        return Icons.sensors;
      case 'assistant_vocal':
        return Icons.record_voice_over;
      default:
        return Icons.device_unknown;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'eclairage':
      case 'lampe':
        return Colors.amber.shade600;
      case 'compteur':
      case 'prise':
        return Colors.blueAccent;
      case 'clim':
      case 'climatisation':
        return Colors.teal;
      case 'gaz':
        return Colors.redAccent;
      case 'assistant_vocal':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _alerteNiveau(double niveau) {
    if (niveau <= 0) {
      return const AlerteBox(
        text: "❌ Bouteille vide. Veuillez changer de bouteille !",
        color: Colors.black87,
        textColor: Colors.white,
      );
    } else if (niveau < 15) {
      return const AlerteBox(
        text: "🚨 Niveau critique ! Le gaz est presque vide.",
        color: Colors.red,
        textColor: Colors.white,
      );
    } else if (niveau < 25) {
      return const AlerteBox(
        text: "⚠️ Niveau bas ! Pensez à surveiller le gaz.",
        color: Colors.orange,
        textColor: Colors.black,
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Détails d'un appareil"),
        elevation: 0,
      ),
      body: _module == null
          ? Center(
              child: _error == null
                  ? const CircularProgressIndicator()
                  : Text(_error!),
            )
          : _buildBody(_module!),
    );
  }

  Widget _buildBody(Module module) {
    final type = module.djangoType;
    final etat = module.etat;
    return Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: _colorFor(type).withOpacity(0.2),
                  child:
                      Icon(_iconFor(type), size: 50, color: _colorFor(type)),
                ),
                const SizedBox(height: 20),
                Text(module.nom,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Type : ${type.toUpperCase()}",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                const SizedBox(height: 20),
                if (type == 'gaz') ...[
                  Text("Niveau : ${module.niveau?.toStringAsFixed(0) ?? '--'} %",
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  CircularPercentIndicator(
                    radius: 100,
                    lineWidth: 13,
                    animation: true,
                    percent: ((module.niveau ?? 0) / 100).clamp(0, 1),
                    center: Text(
                        "${(module.niveau ?? 0).toStringAsFixed(0)}%",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: (module.niveau ?? 0) > 50
                        ? Colors.greenAccent
                        : (module.niveau ?? 0) > 20
                            ? Colors.orangeAccent
                            : Colors.redAccent,
                    backgroundColor: Colors.grey[300]!,
                  ),
                  const SizedBox(height: 20),
                  _alerteNiveau(module.niveau ?? 0),
                  if (module.fuite == true)
                    const AlerteBox(
                      text: "🔥 Fuite de gaz détectée !",
                      color: Colors.redAccent,
                      textColor: Colors.white,
                    ),
                ] else if (type == 'eclairage') ...[
                  Text(etat ? "Lampe allumée 💡" : "Lampe éteinte ⚫",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: etat ? Colors.amber : Colors.grey)),
                  const SizedBox(height: 20),
                  if (etat) ...[
                    const Text("Luminosité",
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    Slider(
                      value: (module.intensite ?? 50).toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 10,
                      activeColor: Colors.amber,
                      label: "${module.intensite ?? 50}%",
                      onChanged: (v) => setState(
                          () => _module = module.copyWith(intensite: v.toInt())),
                      onChangeEnd: (v) => _setIntensite(v.toInt()),
                    ),
                  ],
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: Icon(etat ? Icons.power_off : Icons.lightbulb_outline,
                        size: 26),
                    label: Text(etat ? "Éteindre" : "Allumer",
                        style: const TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          etat ? Colors.redAccent : Colors.amber.shade600,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _toggle,
                  ),
                ] else if (type == 'compteur') ...[
                  Text(etat ? "Prise activée" : "Prise désactivée",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: etat ? Colors.greenAccent : Colors.redAccent)),
                  const SizedBox(height: 20),
                  Text(
                      "Consommation : ${module.consommation.toStringAsFixed(2)} kWh",
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text("Courant : ${module.courant.toStringAsFixed(2)} A",
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _toggle,
                    icon: Icon(
                        etat ? Icons.power_settings_new : Icons.power_off,
                        color: Colors.white),
                    label: Text(etat ? "Éteindre" : "Allumer",
                        style: const TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          etat ? Colors.redAccent : Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ] else if (type == 'clim') ...[
                  Text(etat ? "Climatisation activée ❄️" : "Climatisation éteinte ⚫",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: etat ? Colors.blueAccent : Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(etat ? Icons.power_off : Icons.power, size: 26),
                    label: Text(etat ? "Éteindre" : "Allumer",
                        style: const TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: etat ? Colors.redAccent : Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _toggle,
                  ),
                ] else if (type != 'gaz')
                  ElevatedButton.icon(
                    icon: Icon(etat ? Icons.power_off : Icons.power, size: 26),
                    label: Text(etat ? "Éteindre" : "Allumer",
                        style: const TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: etat ? Colors.redAccent : Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _toggle,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
