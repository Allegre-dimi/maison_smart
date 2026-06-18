

// Modèle représentant un appareil (prise, lumière, gaz...)

class Device {
  final String name;
  final String type; // Ex: 'prise', 'lumière', 'gaz', 'meter'
  bool isOn;

  Device({
    required this.name,
    required this.type,
    this.isOn = false,
  });
}



