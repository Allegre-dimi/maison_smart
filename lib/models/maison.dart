class Maison {
  final String houseId;
  final String name;
  final String ownerId;
  final DateTime createdAt;
  final List<String>? adminIds;
  final List<String>? members;
  final String? code;
  final String? wifiSSID;
  final String? description;
  final bool isActive;
  final String? adresse;
  final String? ville;
  final String? codePostal;
  final String? pays;
  final String? telephone;
  final String? typeMaison;

  /// Rôle calculé côté serveur (`owner` / `admin` / `member`).
  final String? roleUtilisateur;

  Maison({
    required this.houseId,
    required this.name,
    required this.ownerId,
    required this.createdAt,
    this.adminIds,
    this.members,
    this.code,
    this.wifiSSID,
    this.description,
    this.isActive = true,
    this.adresse,
    this.ville,
    this.codePostal,
    this.pays,
    this.telephone,
    this.typeMaison,
    this.roleUtilisateur,
  });

  factory Maison.fromJson(Map<String, dynamic> data) {
    return Maison(
      houseId: (data['id'] ?? data['houseId'] ?? '').toString(),
      name: data['name'] ?? '',
      ownerId: (data['owner_id'] ?? data['ownerId'] ?? '').toString(),
      createdAt: _parseDate(data['created_at'] ?? data['createdAt']) ?? DateTime.now(),
      adminIds: List<String>.from(
          (data['admins'] ?? data['adminIds'] ?? const []).map((e) => e.toString())),
      members: List<String>.from(
          (data['members'] ?? const []).map((e) => e.toString())),
      code: data['code'],
      wifiSSID: data['wifi_ssid'] ?? data['wifiSSID'],
      description: data['description'],
      isActive: data['is_active'] ?? data['isActive'] ?? true,
      adresse: data['adresse'],
      ville: data['ville'],
      codePostal: data['code_postal'] ?? data['codePostal'],
      pays: data['pays'],
      telephone: data['telephone'],
      typeMaison: data['type_maison'] ?? data['typeMaison'],
      roleUtilisateur: data['role_utilisateur'] ?? data['roleUtilisateur'],
    );
  }

  /// Conservé pour rétro-compat — ancien code Firebase.
  factory Maison.fromFirestore(Map<String, dynamic> data, String houseId) {
    final merged = Map<String, dynamic>.from(data);
    merged['id'] = houseId;
    return Maison.fromJson(merged);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': houseId,
      'name': name,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
      'admins': adminIds,
      'members': members,
      'code': code,
      'wifi_ssid': wifiSSID,
      'description': description,
      'is_active': isActive,
      'adresse': adresse,
      'ville': ville,
      'code_postal': codePostal,
      'pays': pays,
      'telephone': telephone,
      'type_maison': typeMaison,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
