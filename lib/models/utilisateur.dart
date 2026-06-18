class Utilisateur {
  final String uid;
  final String email;
  String role;

  /// Liste des maisons où l'utilisateur est propriétaire / admin / membre
  List<String> houseIds;
  String? activeHouseId; // maison actuellement sélectionnée

  final String? displayName;
  final String? fullName;
  String? username;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final String? phoneNumber;

  Utilisateur({
    required this.uid,
    required this.email,
    required this.role,
    this.houseIds = const [],
    this.activeHouseId,
    this.displayName,
    this.fullName,
    this.username,
    this.createdAt,
    this.lastLoginAt,
    this.phoneNumber,
  });

  /// Construit un Utilisateur depuis la réponse Django (`utilisateur` block).
  ///
  /// Le backend renvoie en gros :
  /// ```
  /// {
  ///   "id": "u_demo_001",
  ///   "full_name": "Demo User",
  ///   "email": "demo@ndako.local",
  ///   "username": "demo",
  ///   "role": "user"
  /// }
  /// ```
  factory Utilisateur.fromJson(Map<String, dynamic> data) {
    return Utilisateur(
      uid: (data['id'] ?? data['uid'] ?? '').toString(),
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      houseIds: List<String>.from(
          (data['house_ids'] ?? data['houseIds'] ?? const [])
              .map((e) => e.toString())),
      activeHouseId: data['active_house_id'] ?? data['activeHouseId'],
      displayName: data['display_name'] ?? data['displayName'],
      fullName: data['full_name'] ?? data['fullName'] ?? data['nom'],
      username: data['username'],
      createdAt: _parseDate(data['created_at'] ?? data['createdAt']),
      lastLoginAt: _parseDate(data['last_login_at'] ?? data['lastLoginAt']),
      phoneNumber: data['phone_number'] ?? data['phoneNumber'],
    );
  }

  /// Alias historique pour la rétro-compatibilité de l'ancien code Firebase.
  factory Utilisateur.fromFirestore(Map<String, dynamic> data, String uid) {
    final merged = Map<String, dynamic>.from(data);
    merged['id'] = uid;
    return Utilisateur.fromJson(merged);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': uid,
      'email': email,
      'role': role,
      'house_ids': houseIds,
      'active_house_id': activeHouseId,
      'display_name': displayName,
      'full_name': fullName,
      'username': username,
      'created_at': createdAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'phone_number': phoneNumber,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  Utilisateur copyWith({
    String? uid,
    String? email,
    String? role,
    List<String>? houseIds,
    String? activeHouseId,
    String? displayName,
    String? fullName,
    String? username,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? phoneNumber,
  }) {
    return Utilisateur(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      houseIds: houseIds ?? this.houseIds,
      activeHouseId: activeHouseId ?? this.activeHouseId,
      displayName: displayName ?? this.displayName,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
