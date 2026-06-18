import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/horaire.dart';
import '../models/module.dart';
import '../services/api_client.dart';
import '../services/module_service.dart';

class PriseScreen extends StatefulWidget {
  final String moduleId;
  final String pieceName;

  const PriseScreen({
    super.key,
    required this.moduleId,
    required this.pieceName,
  });

  @override
  State<PriseScreen> createState() => _PriseScreenState();
}

class _PriseScreenState extends State<PriseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int currentTabIndex;
  Timer? simulationTimer;
  Timer? refreshTimer;
  String selectedFilter = "Jour";

  Module? _module;
  String? _error;

  final List<Horaire> _horairesLocaux = [];

  bool priseManuelle = false;
  bool horaireActive = false;
  bool get priseActive => priseManuelle || horaireActive;

  Map<String, List<double>> consommationData = {
    "Jour": List.generate(7, (_) => 0),
    "Semaine": List.generate(4, (_) => 0),
    "Mois": List.generate(12, (_) => 0),
  };

  double mesureCourant = 0.0;
  double consommationActuelle = 0.0;

  final List<Color> _barColors = [
    Colors.blueAccent,
    Colors.redAccent,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    currentTabIndex = _tabController.index;
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() => currentTabIndex = _tabController.index);
    });
    _load();
    refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) => _load());
    _startMonitoring();
  }

  Future<void> _load() async {
    try {
      final m =
          await ModuleService().getModule(widget.moduleId, type: 'compteur');
      if (mounted && m != null) {
        setState(() {
          _module = m;
          priseManuelle = m.etat;
          consommationActuelle = m.consommation;
          mesureCourant = m.courant;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
    _checkHoraireStatus();
  }

  void _startMonitoring() {
    simulationTimer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (priseActive) {
        setState(() {
          mesureCourant = double.parse(
              (Random().nextDouble() * 12 + 3).toStringAsFixed(2));
          consommationActuelle += mesureCourant * 0.002;
          _updateGraphData();
        });
      }
    });
  }

  void _updateGraphData() {
    final list = consommationData[selectedFilter]!;
    list.removeAt(0);
    list.add(consommationActuelle);
  }

  @override
  void dispose() {
    simulationTimer?.cancel();
    refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleManuel(bool newState) async {
    try {
      final updated = await ModuleService()
          .setEtat(widget.moduleId, newState, type: 'compteur');
      if (mounted) setState(() {
        _module = updated;
        priseManuelle = updated.etat;
      });
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${e.message}")));
    }
  }

  void _checkHoraireStatus() {
    final now = DateTime.now();
    final jourStr = const [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ][now.weekday - 1];
    bool actif = false;
    for (final h in _horairesLocaux) {
      if (!h.actif) continue;
      if (h.jours != null &&
          h.jours!.isNotEmpty &&
          !h.jours!.split(',').contains(jourStr)) {
        continue;
      }
      final start = DateTime(now.year, now.month, now.day,
          h.heureDebut.hour, h.heureDebut.minute);
      final end = DateTime(now.year, now.month, now.day, h.heureFin.hour,
          h.heureFin.minute);
      if (now.isAfter(start) && now.isBefore(end)) {
        actif = true;
        _toggleManuel(true);
        break;
      }
    }
    if (mounted) setState(() => horaireActive = actif);
  }

  @override
  Widget build(BuildContext context) {
    if (_module == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Prise - ${widget.pieceName}")),
        body: Center(
          child: _error == null
              ? const CircularProgressIndicator()
              : Text(_error!),
        ),
      );
    }
    final module = _module!;
    return Scaffold(
      appBar: AppBar(
        title: Text("Prise - ${widget.pieceName}"),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black54,
          tabs: const [
            Tab(text: "Contrôle"),
            Tab(text: "Horaires"),
            Tab(text: "Consommation"),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildControleTab(module),
              _buildHoraireTab(),
              _buildConsommationTab(),
            ],
          ),
          if (currentTabIndex == 1)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _showHoraireModal,
                backgroundColor: Colors.deepPurple,
                child: const Icon(Icons.add),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControleTab(Module module) {
    return Center(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(module.nom,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Pièce : ${widget.pieceName}",
                  style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 25),
              GestureDetector(
                onTap: horaireActive
                    ? null
                    : () => _toggleManuel(!priseManuelle),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: priseActive ? Colors.deepPurple : Colors.grey[300],
                    boxShadow: [
                      if (priseActive)
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                    ],
                  ),
                  child: Icon(
                    priseActive ? Icons.power_settings_new : Icons.power_off,
                    color: priseActive ? Colors.white : Colors.black54,
                    size: 65,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                horaireActive
                    ? "Contrôle manuel désactivé car horaire actif"
                    : "Contrôle manuel disponible",
                style: TextStyle(
                  fontSize: 12,
                  color: horaireActive ? Colors.red : Colors.black54,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, color: Colors.amber),
                  const SizedBox(width: 6),
                  Text(
                    "Consommation : ${consommationActuelle.toStringAsFixed(2)} kWh",
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  const Icon(Icons.electric_meter, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  Text(
                    "Courant : ${mesureCourant.toStringAsFixed(2)} A",
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHoraireTab() {
    if (_horairesLocaux.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "Aucun horaire ajouté.\n\nLes horaires sont stockés localement — la synchronisation backend arrive bientôt.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _horairesLocaux.length,
      itemBuilder: (context, index) {
        final h = _horairesLocaux[index];
        final joursAffichage = h.jours != null && h.jours!.isNotEmpty
            ? h.jours!.split(',').join(', ')
            : 'tous les jours';
        return GestureDetector(
          onLongPress: () => _showDeleteConfirmation(context, index),
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                  "De ${h.heureDebut.format(context)} à ${h.heureFin.format(context)}"),
              subtitle: Text("Jours : $joursAffichage"),
              trailing: Switch(
                value: h.actif,
                onChanged: (v) {
                  setState(() {
                    _horairesLocaux[index] = Horaire(
                      id: h.id,
                      moduleId: h.moduleId,
                      heureDebut: h.heureDebut,
                      heureFin: h.heureFin,
                      jours: h.jours,
                      actif: v,
                      type: h.type,
                      temperatureSeuil: h.temperatureSeuil,
                      action: h.action,
                      createdAt: h.createdAt,
                    );
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showHoraireModal() {
    TimeOfDay debut = TimeOfDay.now();
    TimeOfDay fin =
        TimeOfDay.now().replacing(hour: (TimeOfDay.now().hour + 1) % 24);
    final List<String> joursSelectionnes = [];
    const joursSemaine = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Ajouter un horaire"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  const Text("Heure début : "),
                  TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                          context: context, initialTime: debut);
                      if (picked != null) {
                        setDialogState(() => debut = picked);
                      }
                    },
                    child: Text(debut.format(context)),
                  ),
                ]),
                Row(children: [
                  const Text("Heure fin : "),
                  TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                          context: context, initialTime: fin);
                      if (picked != null) {
                        setDialogState(() => fin = picked);
                      }
                    },
                    child: Text(fin.format(context)),
                  ),
                ]),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Sélectionnez les jours :"),
                ),
                Wrap(
                  spacing: 6,
                  children: joursSemaine.map((jour) {
                    final selected = joursSelectionnes.contains(jour);
                    return ChoiceChip(
                      label: Text(jour),
                      selected: selected,
                      onSelected: (v) {
                        setDialogState(() {
                          if (v) {
                            joursSelectionnes.add(jour);
                          } else {
                            joursSelectionnes.remove(jour);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _horairesLocaux.add(Horaire(
                    id: 'local_${_horairesLocaux.length}',
                    moduleId: widget.moduleId,
                    heureDebut: debut,
                    heureFin: fin,
                    jours: joursSelectionnes.join(','),
                    actif: true,
                    type: 'horaire',
                    createdAt: DateTime.now(),
                  ));
                });
                Navigator.pop(context);
              },
              child: const Text("Ajouter"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, int index) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer l'horaire"),
        content: const Text("Voulez-vous vraiment supprimer cet horaire ?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              setState(() => _horairesLocaux.removeAt(index));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }

  Widget _buildConsommationTab() {
    final dataList = consommationData[selectedFilter]!;
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ["Jour", "Semaine", "Mois"].map((f) {
            final selected = f == selectedFilter;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ChoiceChip(
                label: Text(f),
                selected: selected,
                onSelected: (_) => setState(() => selectedFilter = f),
                selectedColor: Colors.deepPurple,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (dataList.reduce(max) + 5),
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: true, reservedSize: 35),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, meta) => Text(
                            "${v.toInt() + 1}",
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    barGroups: dataList.asMap().entries.map((e) {
                      return BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value,
                            color: _barColors[e.key % _barColors.length],
                            width: 14,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
