import 'package:flutter/material.dart';
import 'dart:async';

class DeviceDiscoveryPage extends StatefulWidget {
  const DeviceDiscoveryPage({super.key});

  @override
  State<DeviceDiscoveryPage> createState() => _DeviceDiscoveryPageState();
}

class _DeviceDiscoveryPageState extends State<DeviceDiscoveryPage> {
  bool isScanning = false;
  List<Map<String, String>> discoveredDevices = [];

  Future<void> startScan() async {
    setState(() {
      isScanning = true;
      discoveredDevices.clear();
    });

    // 🔥 Simulation de scan réseau (remplacer plus tard par vrai scan)
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      isScanning = false;
      discoveredDevices = [
        {
          "name": "Prise Salon",
          "ip": "192.168.1.45",
          "type": "prise"
        },
        {
          "name": "Lampe Chambre",
          "ip": "192.168.1.52",
          "type": "lampe"
        },
      ];
    });
  }

  void addDevice(Map<String, String> device) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${device['name']} associé avec succès")),
    );

    // 👉 Ici plus tard on enregistrera dans Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détection des appareils"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: isScanning ? null : startScan,
              icon: const Icon(Icons.wifi_find),
              label: Text(isScanning ? "Scan en cours..." : "Lancer la détection", ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white, // couleur du texte et des icônes
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 20),

            if (isScanning)
              const CircularProgressIndicator(),

            if (!isScanning && discoveredDevices.isEmpty)
              const Text("Aucun appareil détecté"),

            if (discoveredDevices.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: discoveredDevices.length,
                  itemBuilder: (context, index) {
                    final device = discoveredDevices[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.memory, color: Colors.deepPurple),
                        title: Text(device["name"] ?? ""),
                        subtitle: Text("${device["type"]} • IP: ${device["ip"]}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () => addDevice(device),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
