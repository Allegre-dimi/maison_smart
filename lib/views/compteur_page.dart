import 'dart:async';

import 'package:flutter/material.dart';

import '../models/module.dart';
import '../services/api_client.dart';
import '../services/module_service.dart';

class CompteurPage extends StatefulWidget {
  final String moduleId;

  const CompteurPage({Key? key, required this.moduleId}) : super(key: key);

  @override
  State<CompteurPage> createState() => _CompteurPageState();
}

class _CompteurPageState extends State<CompteurPage> {
  double tarifParKwh = 100.0;
  Module? _module;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => _load());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final mod =
          await ModuleService().getModule(widget.moduleId, type: 'compteur');
      if (mounted) setState(() => _module = mod);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _toggle(bool value) async {
    try {
      final updated = await ModuleService()
          .setEtat(widget.moduleId, value, type: 'compteur');
      if (mounted) setState(() => _module = updated);
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.message}")),
      );
    }
  }

  Future<void> _resetConsommation() async {
    try {
      final updated = await ModuleService().commande(
        widget.moduleId,
        action: 'set',
        type: 'compteur',
        payload: {'consommation': 0.0},
      );
      if (!mounted) return;
      setState(() => _module = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Consommation remise à zéro."),
            backgroundColor: Colors.green),
      );
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositif'),
        backgroundColor: Colors.deepPurple,
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
    final double courant = module.courant;
    final double consommation =
        module.consommationActuelle ?? module.consommation;
    final double tension = module.tension ?? 220.0;
    final bool etat = module.etat;
    final double montant = consommation * tarifParKwh;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            color: etat ? Colors.green.shade100 : Colors.red.shade100,
            child: ListTile(
              leading: Icon(
                etat ? Icons.flash_on : Icons.flash_off,
                color: etat ? Colors.green : Colors.red,
                size: 32,
              ),
              title: Text(
                etat ? "Compteur actif" : "Compteur inactif",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Switch(
                value: etat,
                onChanged: _toggle,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            icon: Icons.flash_on,
            title: "Tension",
            value: "${tension.toStringAsFixed(1)} V",
            color: Colors.orangeAccent,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.bolt,
            title: "Courant",
            value: "${courant.toStringAsFixed(2)} A",
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.energy_savings_leaf,
            title: "Consommation",
            value: "${consommation.toStringAsFixed(3)} kWh",
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.attach_money,
            title: "Montant à payer",
            value: "${montant.toStringAsFixed(2)} FC",
            color: Colors.redAccent,
          ),
          const SizedBox(height: 20),
          Text(
            "Tarif unitaire : ${tarifParKwh.toStringAsFixed(0)} FC / kWh",
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: _resetConsommation,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              "Réinitialiser la consommation",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
