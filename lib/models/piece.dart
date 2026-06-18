import 'package:flutter/material.dart';

class Piece {
  final String id;
  final String houseId;
  final String nom;
  final String type;
  final String userId;
  final List<dynamic> appareils;
  final String iconeName;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;
  final bool isActive;

  /// Permissions héritées de la version Firestore (non utilisées côté Django
  /// pour l'instant mais conservées pour compat).
  final List<String> allowedUserIds;
  final Map<String, String> permissions;

  Piece({
    required this.id,
    required this.houseId,
    required this.nom,
    required this.type,
    required this.userId,
    this.appareils = const [],
    required this.iconeName,
    required this.createdAt,
    this.lastModifiedAt,
    this.isActive = true,
    this.allowedUserIds = const [],
    this.permissions = const {},
  });

  factory Piece.fromJson(Map<String, dynamic> data) {
    final iconCp = data['icone_code_point'];
    String iconName = data['iconeName'] ?? data['icone_name'] ?? 'Autre';
    if (iconCp != null && iconName == 'Autre') {
      iconName = _iconNameFromCodePoint(iconCp is int ? iconCp : int.tryParse('$iconCp') ?? 0);
    }
    return Piece(
      id: (data['id'] ?? '').toString(),
      houseId: (data['maison_id'] ?? data['houseId'] ?? '').toString(),
      nom: data['nom'] ?? '',
      type: data['type'] ?? '',
      userId: (data['user_id'] ?? data['userId'] ?? '').toString(),
      appareils: List<dynamic>.from(data['appareils'] ?? const []),
      iconeName: iconName,
      createdAt: _parseDate(data['created_at'] ?? data['createdAt']) ?? DateTime.now(),
      lastModifiedAt: _parseDate(data['last_modified_at'] ?? data['lastModifiedAt']),
      isActive: data['is_active'] ?? data['isActive'] ?? true,
      allowedUserIds:
          List<String>.from((data['allowed_user_ids'] ?? data['allowedUserIds'] ?? const [])
              .map((e) => e.toString())),
      permissions:
          Map<String, String>.from(data['permissions'] ?? const <String, String>{}),
    );
  }

  factory Piece.fromMap(Map<String, dynamic> data, String documentId) {
    final merged = Map<String, dynamic>.from(data);
    merged['id'] = documentId;
    return Piece.fromJson(merged);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maison_id': houseId,
      'nom': nom,
      'type': type,
      'user_id': userId,
      'iconeName': iconeName,
      'icone_font_family': 'MaterialIcons',
      'icone_code_point': icon.codePoint,
      'created_at': createdAt.toIso8601String(),
      'last_modified_at': lastModifiedAt?.toIso8601String(),
      'is_active': isActive,
      'allowed_user_ids': allowedUserIds,
      'permissions': permissions,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  IconData get icon {
    const iconMapping = {
      'Salon': Icons.weekend,
      'Cuisine': Icons.kitchen,
      'Couloir': Icons.bed,
      'Salle de bain': Icons.shower,
      'Chambre': Icons.bed,
      'Bureau': Icons.work,
      'Garage': Icons.garage,
      'Balcon': Icons.balcony,
      'Entrée': Icons.door_front_door,
      'Salle à manger': Icons.chair_alt,
      'Autre': Icons.room,
    };
    return iconMapping[iconeName] ?? Icons.room;
  }

  static String _iconNameFromCodePoint(int cp) {
    if (cp == Icons.weekend.codePoint) return 'Salon';
    if (cp == Icons.kitchen.codePoint) return 'Cuisine';
    if (cp == Icons.shower.codePoint) return 'Salle de bain';
    if (cp == Icons.bed.codePoint) return 'Chambre';
    if (cp == Icons.work.codePoint) return 'Bureau';
    if (cp == Icons.garage.codePoint) return 'Garage';
    if (cp == Icons.balcony.codePoint) return 'Balcon';
    if (cp == Icons.door_front_door.codePoint) return 'Entrée';
    if (cp == Icons.chair_alt.codePoint) return 'Salle à manger';
    return 'Autre';
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
