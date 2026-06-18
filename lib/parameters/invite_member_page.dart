import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_client.dart';
import '../services/maison_service.dart';
import '../services/session_service.dart';

class InviteMemberPage extends StatefulWidget {
  final String userId;

  const InviteMemberPage({super.key, required this.userId});

  @override
  State<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends State<InviteMemberPage> {
  String invitationCode = '';
  bool isLoading = false;
  String joinCode = '';
  final TextEditingController _joinController = TextEditingController();
  final MaisonService _service = MaisonService();

  String? get _activeHouseId =>
      SessionService().utilisateur?.activeHouseId;

  @override
  void initState() {
    super.initState();
    _loadExistingCode();
  }

  Future<void> _loadExistingCode() async {
    final houseId = _activeHouseId;
    if (houseId == null) return;
    try {
      final invites = await _service.listInvitations(houseId);
      final firstActive = invites.firstWhere(
        (e) => (e['is_valid'] == true) || (e['is_used'] == false),
        orElse: () => const <String, dynamic>{},
      );
      final code = firstActive['code'];
      if (code != null) {
        setState(() => invitationCode = code.toString());
      }
    } on ApiException {
      // ignore
    }
  }

  Future<void> _createInvitationCode() async {
    final houseId = _activeHouseId;
    if (houseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucune maison active.")),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      final invite = await _service.createInvitation(houseId);
      final code = invite['code']?.toString() ?? '';
      setState(() => invitationCode = code);
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.message}")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _joinHouse() async {
    final code = joinCode.trim();
    if (code.isEmpty) return;
    try {
      final maison = await _service.acceptInvitation(code);
      await SessionService().setActiveHouse(maison.houseId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous avez rejoint la maison !')),
      );
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inviter un membre"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Générer un code pour inviter un membre",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    invitationCode.isEmpty
                        ? "Aucun code généré"
                        : invitationCode,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    if (invitationCode.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: invitationCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Code copié dans le presse-papier')),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : _createInvitationCode,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Générer un nouveau code"),
            ),
            const SizedBox(height: 30),
            const Text("Rejoindre une maison avec un code",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _joinController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Entrez le code d'invitation",
              ),
              onChanged: (val) => joinCode = val,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _joinHouse,
              child: const Text("Rejoindre la maison"),
            ),
          ],
        ),
      ),
    );
  }
}
