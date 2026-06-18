import 'package:flutter/material.dart';

import '../models/piece.dart';
import '../models/utilisateur.dart';
import '../services/api_client.dart';
import '../services/piece_service.dart';

class AddRoomDialog extends StatefulWidget {
  final Utilisateur utilisateur;
  final String houseId;

  const AddRoomDialog({
    Key? key,
    required this.utilisateur,
    required this.houseId,
  }) : super(key: key);

  @override
  State<AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<AddRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  String nom = '';
  String selectedType = 'Salon';
  bool _isSubmitting = false;

  final Map<String, String> roomTypesWithIcons = const {
    'Salon': 'Salon',
    'Cuisine': 'Cuisine',
    'Couloir': 'Couloir',
    'Salle de bain': 'Salle de bain',
    'Chambre': 'Chambre',
    'Bureau': 'Bureau',
    'Garage': 'Garage',
    'Balcon': 'Balcon',
    'Entrée': 'Entrée',
    'Salle à manger': 'Salle à manger',
    'Autre': 'Autre',
  };

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: const Text("Ajouter une pièce"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nom de la pièce',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Champ requis';
                  if (val.trim().length < 2) return 'Nom trop court';
                  return null;
                },
                onSaved: (val) => nom = val!.trim(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Type de pièce',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                ),
                value: selectedType,
                items: roomTypesWithIcons.keys
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) => setState(() => selectedType = val!),
                validator: (val) => val == null ? 'Sélection obligatoire' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(null),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _saveRoom,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text("Ajouter"),
        ),
      ],
    );
  }

  Future<void> _saveRoom() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState?.save();
    setState(() => _isSubmitting = true);

    try {
      final Piece piece = await PieceService().createPiece(
        nom: nom,
        type: selectedType,
        houseId: widget.houseId,
        iconeName: selectedType,
      );

      if (mounted) {
        Navigator.of(context).pop(piece);
      }
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.message}")),
      );
      setState(() => _isSubmitting = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'ajout : $e")),
      );
      setState(() => _isSubmitting = false);
    }
  }
}
