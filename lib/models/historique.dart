class Historique {
  final String id;
  final String pieceId;
  final String moduleId;
  final DateTime timestamp;
  final double niveau;
  final double poids;
  final double valeur;
  final double temperature;

  Historique({
    required this.id,
    required this.pieceId,
    required this.moduleId,
    required this.timestamp,
    required this.niveau,
    required this.poids,
    required this.valeur,
    required this.temperature,
  });

  factory Historique.fromJson(Map<String, dynamic> data, [String? id]) {
    return Historique(
      id: (id ?? data['id'] ?? '').toString(),
      pieceId: (data['pieceId'] ?? data['piece_id'] ?? '').toString(),
      moduleId: (data['moduleId'] ?? data['module_id'] ?? '').toString(),
      timestamp: _parseDate(data['timestamp']) ?? DateTime.now(),
      niveau: _toDouble(data['niveau']),
      poids: _toDouble(data['poids']),
      valeur: _toDouble(data['valeur']),
      temperature: _toDouble(data['temperature']),
    );
  }

  factory Historique.fromMap(Map<String, dynamic> data, String documentId) =>
      Historique.fromJson(data, documentId);

  Map<String, dynamic> toMap() => {
        'pieceId': pieceId,
        'moduleId': moduleId,
        'timestamp': timestamp.toIso8601String(),
        'niveau': niveau,
        'poids': poids,
        'valeur': valeur,
        'temperature': temperature,
      };

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
