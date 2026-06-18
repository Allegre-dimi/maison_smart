import 'dart:async';

import 'package:flutter/material.dart';

import '../models/maison.dart';
import '../models/piece.dart';
import '../models/utilisateur.dart';
import '../services/api_client.dart';
import '../services/maison_service.dart';
import '../services/piece_service.dart';
import 'add_room_form2.dart';
import 'piece_detail_page_grille.dart';

class GrillePage extends StatefulWidget {
  final bool isDarkMode;
  final String houseId;
  final Utilisateur utilisateur;

  const GrillePage({
    Key? key,
    required this.houseId,
    required this.isDarkMode,
    required this.utilisateur,
  }) : super(key: key);

  @override
  State<GrillePage> createState() => _GrillePageState();
}

class _GrillePageState extends State<GrillePage> {
  final PieceService _pieceService = PieceService();
  final MaisonService _maisonService = MaisonService();

  bool _loadingPermissions = true;
  bool _isOwnerOrAdmin = false;
  Future<List<Piece>>? _piecesFuture;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() => _piecesFuture = _loadPieces());
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAll() async {
    try {
      final Maison? maison = await _maisonService.getMaison(widget.houseId);
      _isOwnerOrAdmin = maison?.ownerId == widget.utilisateur.uid ||
          (maison?.adminIds ?? const []).contains(widget.utilisateur.uid);
    } catch (_) {
      _isOwnerOrAdmin = false;
    }
    if (!mounted) return;
    setState(() {
      _loadingPermissions = false;
      _piecesFuture = _loadPieces();
    });
  }

  Future<List<Piece>> _loadPieces() =>
      _pieceService.listPieces(houseId: widget.houseId);

  Future<void> _refresh() async {
    setState(() => _piecesFuture = _loadPieces());
    await _piecesFuture;
  }

  void _openPieceDetail(Piece piece) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PieceDetailPage(
          piece: piece,
          isDarkMode: widget.isDarkMode,
          utilisateur: widget.utilisateur,
        ),
      ),
    ).then((_) => _refresh());
  }

  void _showAddRoomDialog() async {
    if (!_isOwnerOrAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              "Seuls le propriétaire et les admins peuvent ajouter des pièces"),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }
    final piece = await showDialog<Piece>(
      context: context,
      builder: (_) => AddRoomDialog(
        utilisateur: widget.utilisateur,
        houseId: widget.houseId,
      ),
    );
    if (piece != null) {
      _refresh();
    }
  }

  Future<void> _deletePiece(Piece piece) async {
    if (!_isOwnerOrAdmin) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Supprimer la pièce "${piece.nom}" supprimera aussi tous les appareils et horaires liés.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _pieceService.supprimerPiece(piece.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Pièce supprimée avec succès"),
        backgroundColor: Colors.green,
      ));
      _refresh();
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Erreur : ${e.message}"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode ? Colors.black : Colors.grey[50];
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;

    if (_loadingPermissions) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Mes pièces"),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (_isOwnerOrAdmin)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.verified_user),
            )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Piece>>(
          future: _piecesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("Erreur : ${snapshot.error}",
                    style: TextStyle(color: textColor)),
              );
            }
            final pieces = snapshot.data ?? const [];
            final itemCount = pieces.length + (_isOwnerOrAdmin ? 1 : 0);

            if (pieces.isEmpty && !_isOwnerOrAdmin) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline,
                        size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text("Aucune pièce accessible",
                        style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Le propriétaire doit vous donner l'accès",
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (_isOwnerOrAdmin && index == pieces.length) {
                  return GestureDetector(
                    onTap: _showAddRoomDialog,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.deepPurple),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.deepPurple),
                          SizedBox(height: 6),
                          Text("Ajouter une pièce",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)),
                        ],
                      ),
                    ),
                  );
                }
                final piece = pieces[index];
                return GestureDetector(
                  onTap: () => _openPieceDetail(piece),
                  onLongPress: () => _deletePiece(piece),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isDarkMode ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(piece.icon, size: 35, color: Colors.blue),
                        const SizedBox(height: 6),
                        Text(
                          piece.nom,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
