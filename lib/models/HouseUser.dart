class HouseUser {
  final String userId;
  final String houseId;
  final String role; // owner, admin, member
  final DateTime joinedAt;
  final bool isActive;

  HouseUser({
    required this.userId,
    required this.houseId,
    required this.role,
    required this.joinedAt,
    this.isActive = true,
  });

  factory HouseUser.fromJson(Map<String, dynamic> data) {
    DateTime joined = DateTime.now();
    final raw = data['joinedAt'] ?? data['joined_at'];
    if (raw is DateTime) {
      joined = raw;
    } else if (raw is int) {
      joined = DateTime.fromMillisecondsSinceEpoch(raw);
    } else if (raw is String) {
      joined = DateTime.tryParse(raw) ?? DateTime.now();
    }
    return HouseUser(
      userId: (data['userId'] ?? data['user_id'] ?? '').toString(),
      houseId: (data['houseId'] ?? data['house_id'] ?? '').toString(),
      role: (data['role'] ?? 'member').toString(),
      joinedAt: joined,
      isActive: data['isActive'] ?? data['is_active'] ?? true,
    );
  }

  /// Alias compat pour l'ancien code Firestore.
  factory HouseUser.fromFirestore(Map<String, dynamic> data) =>
      HouseUser.fromJson(data);

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'houseId': houseId,
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toMap() => toJson();
}
