import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../models/module.dart';
import '../services/api_client.dart';
import '../services/module_service.dart';
import '../widgets/alert_box.dart';

class GazPage extends StatefulWidget {
  final String moduleId;

  const GazPage({Key? key, required this.moduleId}) : super(key: key);

  @override
  State<GazPage> createState() => _GazPageState();
}

class _GazPageState extends State<GazPage> {
  Module? _module;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) => _load());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final m = await ModuleService().getModule(widget.moduleId, type: 'gaz');
      if (mounted && m != null) setState(() => _module = m);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Widget _alerteNiveau(double niveau) {
    if (niveau <= 0) {
      return const AlerteBox(
          text: "❌ Bouteille vide !",
          color: Colors.black87,
          textColor: Colors.white);
    } else if (niveau < 15) {
      return const AlerteBox(
          text: "🚨 Niveau critique !",
          color: Colors.red,
          textColor: Colors.white);
    } else if (niveau < 25) {
      return const AlerteBox(
          text: "⚠️ Niveau bas !",
          color: Colors.orange,
          textColor: Colors.black);
    }
    return const SizedBox.shrink();
  }

  Widget _alerteFuite(bool fuite) {
    if (!fuite) return const SizedBox.shrink();
    return const AlerteBox(
      text: "🔥 FUITE DE GAZ DÉTECTÉE !",
      color: Colors.redAccent,
      textColor: Colors.white,
    );
  }

  Widget _alerteTemperature(double t) {
    if (t >= 60) {
      return const AlerteBox(
          text: "🔥 Température critique !",
          color: Colors.red,
          textColor: Colors.white);
    } else if (t >= 40) {
      return const AlerteBox(
          text: "⚠️ Température élevée",
          color: Colors.orange,
          textColor: Colors.black);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détecteur de gaz"),
        backgroundColor: Colors.deepPurple,
      ),
      body: _module == null
          ? Center(
              child: _error == null
                  ? const CircularProgressIndicator()
                  : Text(_error!))
          : _buildBody(_module!),
    );
  }

  Widget _buildBody(Module module) {
    final niveau = module.niveau ?? 0.0;
    final temperature = module.temperatureGaz ?? module.temperature ?? 0.0;
    final fuite = module.fuite ?? false;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(module.nom,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  CircularPercentIndicator(
                    radius: 100,
                    lineWidth: 14,
                    animation: true,
                    percent: (niveau / 100).clamp(0.0, 1.0),
                    center: Text("${niveau.toStringAsFixed(0)}%",
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    footer: const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text("Niveau de gaz"),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: niveau > 50
                        ? Colors.greenAccent
                        : niveau > 20
                            ? Colors.orangeAccent
                            : Colors.redAccent,
                    backgroundColor: Colors.grey[300]!,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _alerteFuite(fuite),
          _alerteNiveau(niveau),
          _alerteTemperature(temperature),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.thermostat, color: Colors.redAccent),
              title: const Text("Température"),
              trailing: Text("${temperature.toStringAsFixed(1)} °C",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.fitness_center, color: Colors.indigo),
              title: const Text("Poids"),
              trailing: Text("${(module.poids ?? 0).toStringAsFixed(2)} kg",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.warning, color: Colors.deepOrange),
              title: const Text("Seuil d'alerte"),
              trailing: Text(
                  "${(module.seuilAlerteGaz ?? 20).toStringAsFixed(0)} %",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("Actualiser"),
            onPressed: _load,
          ),
        ],
      ),
    );
  }
}
