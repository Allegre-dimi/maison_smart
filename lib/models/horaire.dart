import 'package:flutter/material.dart';

/// Horaire générique pour un module (allumage/extinction).
///
/// La persistence côté Django se fera dans une future app `schedules` — pour
/// l'instant ce modèle reste utilisé côté UI uniquement, avec
/// `fromJson` / `toJson` REST.
class Horaire {
  final String id;
  final String moduleId;
  final TimeOfDay heureDebut;
  final TimeOfDay heureFin;
  final String? jours;
  final bool actif;
  final String type; // 'horaire' ou 'temperature'
  final int? temperatureSeuil;
  final String? action; // 'allumer' | 'eteindre'
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

  /// Compat ancien code (`fromFirestore(doc)`) — accepte un Map JSON
  /// directement (avec `id` inclus).
  factory Horaire.fromFirestore(dynamic snapshotOrMap) {
    final Map<String, dynamic> data;
    final String id;
    if (snapshotOrMap is Map<String, dynamic>) {
      data = snapshotOrMap;
      id = (data['id'] ?? '').toString();
    } else {
      // Compat : accepte un objet avec .id et .data() (legacy)
      try {
        data = (snapshotOrMap.data() as Map<String, dynamic>);
        id = snapshotOrMap.id as String;
      } catch (_) {
        throw ArgumentError('Format non supporté pour Horaire.fromFirestore');
      }
    }
    return Horaire.fromJson(data, id: id);
  }

  factory Horaire.fromJson(Map<String, dynamic> data, {String? id}) {
    TimeOfDay heureDebut = const TimeOfDay(hour: 0, minute: 0);
    TimeOfDay heureFin = const TimeOfDay(hour: 0, minute: 0);
    if (data['heure_debut'] is String) {
      heureDebut = _stringToTimeOfDay(data['heure_debut'] as String);
    }
    if (data['heure_fin'] is String) {
      heureFin = _stringToTimeOfDay(data['heure_fin'] as String);
    }
    return Horaire(
      id: (id ?? data['id'] ?? '').toString(),
      moduleId: (data['moduleId'] ?? data['module_id'] ?? '').toString(),
      heureDebut: heureDebut,
      heureFin: heureFin,
      jours: data['jours'] as String?,
      actif: (data['actif'] as bool?) ?? true,
      type: (data['type'] as String?) ?? 'horaire',
      temperatureSeuil: data['temperatureSeuil'] is int
          ? data['temperatureSeuil'] as int
          : (data['temperature_seuil'] is int
              ? data['temperature_seuil'] as int
              : null),
      action: data['action'] as String?,
      createdAt: _parseDate(data['createdAt'] ?? data['created_at']) ??
          DateTime.now(),
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

  static String _timeOfDayToString(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  static TimeOfDay _stringToTimeOfDay(String s) {
    final parts = s.split(':');
    return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  @override
  String toString() {
    if (type == 'horaire') {
      return 'Horaire{id: $id, moduleId: $moduleId, heureDebut: $heureDebut, heureFin: $heureFin, jours: $jours, actif: $actif}';
    }
    return 'HoraireTemp{id: $id, moduleId: $moduleId, tempSeuil: $temperatureSeuil, action: $action, jours: $jours, actif: $actif}';
  }
}
