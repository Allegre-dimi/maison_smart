class Invitation {
  final String id;
  final String emailInvite;
  final String maisonId;
  final String status; // "pending", "accepted", "rejected"

  Invitation({
    required this.id,
    required this.emailInvite,
    required this.maisonId,
    this.status = "pending",
  });

  factory Invitation.fromMap(Map<String, dynamic> data, String documentId) {
    return Invitation(
      id: documentId,
      emailInvite: data['emailInvite'],
      maisonId: data['maisonId'],
      status: data['status'] ?? "pending",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'emailInvite': emailInvite,
      'maisonId': maisonId,
      'status': status,
    };
  }
}
