import 'package:flutter/material.dart';

/// Variante d'horaire utilisée par l'écran climatisation.
class Horaire {
  final String id;
  final String moduleId;
  final TimeOfDay heureDebut;
  final TimeOfDay heureFin;
  final String? jours;
  final bool actif;
  final String type;
  final int? temperatureSeuil;
  final String? action;
  final DateTime createdAt;

  Horaire({
    required this.id,
    required this.moduleId,
    required this.heureDebut,
    required this.heureFin,
    this.jours,
    required this.actif,
    required this.type,
    this.temperatureSeuil,
    this.action,
    required this.createdAt,
  });

  static String _timeOfDayToString(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  static TimeOfDay _stringToTimeOfDay(String s) {
    final p = s.split(':');
    return TimeOfDay(
        hour: int.tryParse(p[0]) ?? 0,
        minute: int.tryParse(p.length > 1 ? p[1] : '0') ?? 0);
  }

  factory Horaire.fromFirestore(dynamic input) {
    if (input is Map<String, dynamic>) return Horaire.fromJson(input);
    try {
      final data = input.data() as Map<String, dynamic>;
      return Horaire.fromJson({...data, 'id': input.id});
    } catch (_) {
      throw ArgumentError('Format non supporté');
    }
  }

  factory Horaire.fromJson(Map<String, dynamic> data) {
    TimeOfDay heureDebut = const TimeOfDay(hour: 0, minute: 0);
    TimeOfDay heureFin = const TimeOfDay(hour: 0, minute: 0);
    if (data['heure_debut'] is String) {
      heureDebut = _stringToTimeOfDay(data['heure_debut'] as String);
    }
    if (data['heure_fin'] is String) {
      heureFin = _stringToTimeOfDay(data['heure_fin'] as String);
    }
    return Horaire(
      id: (data['id'] ?? '').toString(),
      moduleId: (data['moduleId'] ?? data['module_id'] ?? '').toString(),
      heureDebut: heureDebut,
      heureFin: heureFin,
      jours: data['jours'] as String?,
      actif: (data['actif'] as bool?) ?? true,
      type: (data['type'] as String?) ?? 'horaire',
      temperatureSeuil: data['temperatureSeuil'] is int
          ? data['temperatureSeuil'] as int
          : null,
      action: data['action'] as String?,
      createdAt: data['createdAt'] is String
          ? (DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'moduleId': moduleId,
      'jours': jours,
      'actif': actif,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
    if (type == 'horaire') {
      map['heure_debut'] = _timeOfDayToString(heureDebut);
      map['heure_fin'] = _timeOfDayToString(heureFin);
    } else if (type == 'temperature') {
      if (temperatureSeuil != null) map['temperatureSeuil'] = temperatureSeuil;
      if (action != null) map['action'] = action;
    }
    return map;
  }
}
