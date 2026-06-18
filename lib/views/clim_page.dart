import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/module.dart';
import '../services/api_client.dart';
import '../services/module_service.dart';

class ClimPage extends StatefulWidget {
  final String moduleId;
  final Map<String, dynamic> moduleData;
  final bool isDarkMode;

  const ClimPage({
    Key? key,
    required this.moduleId,
    required this.moduleData,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<ClimPage> createState() => _ClimPageState();
}

class _ClimPageState extends State<ClimPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentTabIndex = 0;

  Module? _module;
  String? _error;
  Timer? simulationTimer;
  Timer? refreshTimer;

  String selectedFilter = "Jour";
  Map<String, List<double>> consommationData = {
    "Jour": List.generate(7, (_) => 0),
    "Semaine": List.generate(4, (_) => 0),
    "Mois": List.generate(12, (_) => 0),
  };
  final List<Color> _barColors = [
    Colors.blueAccent,
    Colors.redAccent,
    Colors.green
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() => currentTabIndex = _tabController.index);
    });
    _load();
    refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) => _load());
    simulationTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_module?.etat ?? false) {
        setState(() {
          final m = _module!;
          m.mesureCourant = double.parse(
              (Random().nextDouble() * 1.5 + 0.5).toStringAsFixed(2));
          m.consommationActuelle =
              (m.consommationActuelle ?? 0) + (m.mesureCourant! * 0.001);
          final list = consommationData[selectedFilter]!;
          list.removeAt(0);
          list.add(m.consommationActuelle ?? 0);
        });
      }
    });
  }

  Future<void> _load() async {
    try {
      final m = await ModuleService().getModule(widget.moduleId, type: 'clim');
      if (mounted && m != null) setState(() => _module = m);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  void dispose() {
    simulationTimer?.cancel();
    refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleEtat() async {
    final m = _module;
    if (m == null) return;
    try {
      final updated = await ModuleService()
          .setEtat(widget.moduleId, !m.etat, type: 'clim');
      if (mounted) setState(() => _module = updated);
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${e.message}")));
    }
  }

  Future<void> _setTempCible(double value) async {
    try {
      final updated = await ModuleService().commande(
        widget.moduleId,
        action: 'set',
        type: 'clim',
        payload: {'temperature_cible': value},
      );
      if (mounted) setState(() => _module = updated);
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${e.message}")));
    }
  }

  Future<void> _setMode(String mode) async {
    try {
      final updated = await ModuleService().commande(
        widget.moduleId,
        action: 'set',
        type: 'clim',
        payload: {'mode': mode},
      );
      if (mounted) setState(() => _module = updated);
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${e.message}")));
    }
  }

  Future<void> _setVitesse(int v) async {
    try {
      final updated = await ModuleService().commande(
        widget.moduleId,
        action: 'set',
        type: 'clim',
        payload: {'vitesse_ventilateur': v},
      );
      if (mounted) setState(() => _module = updated);
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${e.message}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_module == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Climatisation")),
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
        title: Text("Climatisation - ${module.nom}"),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black54,
          tabs: const [
            Tab(text: "Contrôle"),
            Tab(text: "Modes"),
            Tab(text: "Consommation"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildControleTab(module),
          _buildModesTab(module),
          _buildConsommationTab(),
        ],
      ),
    );
  }

  Widget _buildControleTab(Module module) {
    final tempCible = module.temperatureCible ?? 22.0;
    final tempActu = module.temperature ?? 24.0;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(module.nom,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text("Température actuelle : ${tempActu.toStringAsFixed(1)}°C",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _toggleEtat,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: module.etat ? Colors.deepPurple : Colors.grey[300],
                      boxShadow: [
                        if (module.etat)
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                      ],
                    ),
                    child: Icon(
                      module.etat ? Icons.ac_unit : Icons.power_off,
                      color: module.etat ? Colors.white : Colors.black54,
                      size: 65,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  module.etat ? "Climatisation activée" : "Climatisation éteinte",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: module.etat ? Colors.blueAccent : Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                Text("Température consigne : ${tempCible.toStringAsFixed(0)}°C",
                    style: const TextStyle(fontSize: 16)),
                Slider(
                  value: tempCible.clamp(16, 30),
                  min: 16,
                  max: 30,
                  divisions: 14,
                  label: "${tempCible.toStringAsFixed(0)}°C",
                  activeColor: Colors.blueAccent,
                  onChanged: (v) {
                    setState(() {
                      _module = module.copyWith(temperatureCible: v);
                    });
                  },
                  onChangeEnd: _setTempCible,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModesTab(Module module) {
    final modes = const [
      ('cool', 'Froid', Icons.ac_unit),
      ('heat', 'Chaud', Icons.whatshot),
      ('fan', 'Ventilation', Icons.air),
      ('dry', 'Déshumidification', Icons.water_drop_outlined),
      ('auto', 'Auto', Icons.tune),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("Mode courant : ${module.mode ?? 'inconnu'}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: modes
              .map((e) => ChoiceChip(
                    avatar: Icon(e.$3, size: 18),
                    label: Text(e.$2),
                    selected: module.mode == e.$1,
                    onSelected: (_) => _setMode(e.$1),
                  ))
              .toList(),
        ),
        const SizedBox(height: 24),
        const Text("Vitesse du ventilateur",
            style: TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: (module.puissance ?? 0).clamp(0, 5).toDouble(),
          min: 0,
          max: 5,
          divisions: 5,
          label: "${(module.puissance ?? 0).toInt()}",
          onChanged: (v) {
            setState(() => _module = module.copyWith(puissance: v));
          },
          onChangeEnd: (v) => _setVitesse(v.toInt()),
        ),
      ],
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
