import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ndako/parameters/parametres.dart';
import 'package:provider/provider.dart';

import '../models/maison.dart';
import '../models/module.dart';
import '../models/piece.dart';
import '../models/utilisateur.dart';
import '../screens/theme_provider.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/commande_parser_service.dart';
import '../services/eps32_service.dart';
import '../services/maison_service.dart';
import '../services/module_service.dart';
import '../services/piece_service.dart';
import '../services/speech_to_test_service.dart';
import '../services/tts_service.dart';
import 'add_room_form2.dart';
import 'favoris_page.dart';
import 'grille_page.dart';
import 'modules_page_rapide.dart';
import 'profils_page.dart';
import 'select_house_page.dart';

class HomePage3 extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  final Utilisateur utilisateur;

  const HomePage3({
    Key? key,
    required this.utilisateur,
    required this.onToggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _HomePage3State createState() => _HomePage3State();
}

class _HomePage3State extends State<HomePage3> {
  // Getters branchés sur ThemeProvider — dispos même dans les helpers
  // sans BuildContext explicite (ex. _buildDrawer, _buildTabsRow).
  bool get isDarkMode => context.watch<ThemeProvider>().isDarkMode;
  VoidCallback get onToggleTheme =>
      context.read<ThemeProvider>().toggleTheme;

  final CommandeParserService _commandeParser = CommandeParserService();
  final TTSService _ttsService = TTSService();
  final SpeechService _speechService = SpeechService();
  final ESP32Service _esp32Service = ESP32Service();
  final PieceService _pieceService = PieceService();
  final MaisonService _maisonService = MaisonService();
  final ModuleService _moduleService = ModuleService();

  bool _isLoadingUser = true;
  bool _hasGreeted = false;
  bool _canAddDevice = false;
  bool _loadingPermissions = true;
  bool _isOwnerOrAdmin = false;
  Maison? _maison;
  Timer? _refreshTimer;

  bool canViewPiece(Piece piece) {
    if (_loadingPermissions) return false;
    return _isOwnerOrAdmin || piece.userId == widget.utilisateur.uid;
  }

  @override
  void initState() {
    super.initState();
    _loadAll();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) => _refreshMaison());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAll() async {
    try {
      final me = await AuthService().me();
      widget.utilisateur.username = me.username ?? me.fullName ?? "Utilisateur";
      widget.utilisateur.role = me.role;
      await _refreshMaison(initial: true);
      _speakWelcomeOnce();
    } catch (_) {
      widget.utilisateur.username ??= "Utilisateur";
      setState(() {
        _isLoadingUser = false;
        _loadingPermissions = false;
      });
      _speakWelcomeOnce();
    }
  }

  Future<void> _refreshMaison({bool initial = false}) async {
    final houseId = widget.utilisateur.activeHouseId;
    if (houseId == null) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
          _loadingPermissions = false;
        });
      }
      return;
    }
    try {
      final maison = await _maisonService.getMaison(houseId);
      if (!mounted) return;
      final isOwner = maison?.ownerId == widget.utilisateur.uid;
      final isAdmin = maison?.adminIds?.contains(widget.utilisateur.uid) ?? false;
      setState(() {
        _maison = maison;
        _isOwnerOrAdmin = isOwner || isAdmin;
        _canAddDevice = _isOwnerOrAdmin;
        if (initial) _isLoadingUser = false;
        _loadingPermissions = false;
      });
    } catch (_) {
      if (initial && mounted) {
        setState(() {
          _isLoadingUser = false;
          _loadingPermissions = false;
        });
      }
    }
  }

  void _speakWelcomeOnce() {
    if (!_hasGreeted) {
      _hasGreeted = true;
      _ttsService.speak(_getWelcomeMessage(), 'fr');
    }
  }

  String _getWelcomeMessage() {
    if (_isLoadingUser) return "Chargement...";
    final hour = DateTime.now().hour;
    final name = widget.utilisateur.username ?? "Utilisateur";
    if (hour < 12) return "Bonjour, $name";
    if (hour < 18) return "Bon après-midi, $name";
    return "Bonsoir, $name";
  }

  Future<void> _startVoiceInteraction(BuildContext context) async {
    bool continuer = true;
    while (continuer) {
      final result = await showDialog<Map<String, String>>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const VoiceRecognitionDialog(
          message: "Choisissez la langue puis parlez...",
        ),
      );

      if (result == null) break;

      final recognizedText = result['text'] ?? "";
      final language = result['language'] ?? "français";
      final langCode = _toLangCode(language);

      if (recognizedText.isEmpty) {
        await _ttsService.speak(
          langCode == 'fr'
              ? 'Je n\'ai rien entendu 😕'
              : langCode == 'en'
                  ? 'I did not hear anything 😕'
                  : 'Nayoki eloko te 😕',
          langCode,
        );
        break;
      }

      final reponse = await _commandeParser.analyserCommande(
        recognizedText,
        langCode,
        userId: widget.utilisateur.uid,
        houseId: widget.utilisateur.activeHouseId,
      );

      await _ttsService.speak(reponse, langCode);

      if (_commandeParser.lastAction != null &&
          _commandeParser.lastTargets.isNotEmpty) {
        await _esp32Service.executerCommande({
          'action': _commandeParser.lastAction,
          'appareils': _commandeParser.lastTargets,
        }, userId: widget.utilisateur.uid);
      }

      continuer = false;
    }
  }

  String _toLangCode(String lang) {
    lang = lang.toLowerCase().trim();
    if (lang.contains('fran')) return 'fr';
    if (lang.contains('angl')) return 'en';
    if (lang.contains('lingala') || lang.contains('ln')) return 'ln';
    return 'fr';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.utilisateur.activeHouseId == null) {
      return SelectHousePage(utilisateur: widget.utilisateur);
    }
    if (_isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final maison = _maison;
    if (maison == null) {
      return SelectHousePage(utilisateur: widget.utilisateur);
    }
    final isOwner = widget.utilisateur.uid == maison.ownerId;
    if (!maison.isActive && !isOwner) {
      return _buildHouseDisabledScreen(context, maison);
    }
    return _buildNormalHome(context, maison, isOwner);
  }

  Widget _buildHouseDisabledScreen(BuildContext context, Maison maison) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        title: const Text("Maison désactivée"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pause_circle_filled, size: 100, color: Colors.grey[400]),
              const SizedBox(height: 30),
              const Text(
                "🚫 Maison désactivée",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                "La maison '${maison.name}' est actuellement désactivée par le propriétaire.\n\n"
                "Vous ne pouvez pas accéder à ses fonctionnalités pour le moment.\n\n"
                "Contactez le propriétaire pour demander sa réactivation.",
                style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectHousePage(utilisateur: widget.utilisateur),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text("Retour au choix de maison"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNormalHome(BuildContext context, Maison maison, bool isOwner) {
    // Lit le thème actuel via Provider pour que le toggle soit live, plutôt
    // que via isDarkMode (qui peut être stale si le parent ne watch pas).
    final tp = context.watch<ThemeProvider>();
    final isDarkMode = tp.isDarkMode;
    final onToggleTheme = tp.toggleTheme;
    final iconColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_open, color: iconColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          if (!maison.isActive && isOwner)
            Tooltip(
              message: "Maison désactivée - Seul vous pouvez y accéder",
              child: Container(
                margin: const EdgeInsets.only(right: 10, top: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.pause_circle_filled, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text("Désactivée",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              isDarkMode
                  ? Icons.wb_sunny_outlined
                  : Icons.nightlight_round_outlined,
              color: iconColor,
            ),
            onPressed: onToggleTheme,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilsPage()),
              ),
              child: const CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.person_outline, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshMaison,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getWelcomeMessage(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (!maison.isActive && isOwner)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          "⚠️ Votre maison est désactivée. Les autres membres ne peuvent pas y accéder.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _buildTabsRow(),
              const SizedBox(height: 38),
              Image.asset('images/img_home.png', height: 160),
              const SizedBox(height: 28),
              Text(
                "Ajoutez vos appareils préférés pour y accéder facilement",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              Tooltip(
                message: _canAddDevice
                    ? "Cliquez pour ajouter un nouvel appareil"
                    : "Vous n'avez pas la permission d'ajouter des appareils",
                child: ElevatedButton.icon(
                  onPressed: _canAddDevice
                      ? () => _showAddDeviceDialog(widget.utilisateur)
                      : null,
                  icon: Icon(Icons.add_circle_outline,
                      color: _canAddDevice ? Colors.deepPurple : Colors.grey[400]),
                  label: Text(
                    "Ajouter un appareil",
                    style: TextStyle(
                      color: _canAddDevice ? Colors.deepPurple : Colors.grey[400],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canAddDevice
                        ? Colors.deepPurple.shade100
                        : Colors.grey[300],
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                  ),
                ),
              ),
              if (!_canAddDevice)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "Demandez au propriétaire la permission d'ajouter des appareils",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ParametragesPage(
                  utilisateur: widget.utilisateur,
                  isDarkMode: isDarkMode,
                  onToggleTheme: onToggleTheme,
                ),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_filled), label: "Accueil"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: "Paramètres"),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () async => await _startVoiceInteraction(context),
        child: const Icon(Icons.mic_none, color: Colors.white),
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text('Ndako',
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          const ListTile(
              leading: Icon(Icons.dashboard), title: Text('Tableau de bord')),
          ListTile(
            leading: const Icon(Icons.home_filled),
            title: const Text('Modules rapides'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ModulesPageRapide(
                    utilisateur: widget.utilisateur,
                    isDarkMode: isDarkMode,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Changer de maison'),
            subtitle: _maison != null
                ? Text(_maison!.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis)
                : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SelectHousePage(utilisateur: widget.utilisateur),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Se déconnecter',
                style: TextStyle(fontWeight: FontWeight.w500)),
            onTap: () async {
              await AuthService().logout();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTab("Favoris", Icons.favorite_border, Colors.pink.shade100,
            Colors.pink, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FavorisPage(
                isDarkMode: isDarkMode,
                utilisateur: widget.utilisateur,
              ),
            ),
          );
        }),
        const SizedBox(width: 12),
        _buildTab(
          "Grille",
          Icons.grid_view_outlined,
          Colors.deepPurple.shade100,
          Colors.deepPurple,
          () {
            final houseId = widget.utilisateur.activeHouseId;
            if (houseId != null && houseId.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GrillePage(
                    houseId: houseId,
                    isDarkMode: isDarkMode,
                    utilisateur: widget.utilisateur,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Aucune maison active.")),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildTab(String label, IconData icon, Color bgColor, Color iconColor,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: iconColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showAddDeviceDialog(Utilisateur utilisateur) async {
    final houseId = utilisateur.activeHouseId;
    if (houseId == null || houseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vous n'êtes affilié à aucune maison.")),
      );
      return;
    }

    final TextEditingController nomController = TextEditingController();
    String? selectedType;
    String? selectedPiece;
    bool isSubmitting = false;
    // 'assistant_vocal' volontairement absent : ce n'est pas un appareil
    // ajoutable mais le système qui permet de piloter l'app à la voix.
    final List<String> typesModules = [
      "prise",
      "lampe",
      "gaz",
      "climatisation",
      "compteur",
    ];

    final pieces = await _pieceService.listPieces(houseId: houseId);
    final accessiblePieces = pieces.where(canViewPiece).toList();

    if (!mounted) return;

    if (accessiblePieces.isEmpty) {
      // Pas de pièce disponible — proposer d'en créer une
      final shouldCreate = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Aucune pièce"),
          content: const Text(
              "Vous devez créer une pièce avant de pouvoir ajouter un appareil."),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Annuler")),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Créer une pièce")),
          ],
        ),
      );
      if (shouldCreate == true && mounted) {
        final newPiece = await showDialog<Piece>(
          context: context,
          builder: (_) => AddRoomDialog(utilisateur: utilisateur, houseId: houseId),
        );
        if (newPiece != null) {
          _showAddDeviceDialog(utilisateur);
        }
      }
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateSB) => AlertDialog(
          title: const Text("Ajouter un appareil"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomController,
                  decoration: const InputDecoration(
                      labelText: "Nom de l'appareil",
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                      labelText: "Type d'appareil",
                      border: OutlineInputBorder()),
                  items: typesModules
                      .map((type) => DropdownMenuItem(
                          value: type, child: Text(type.toUpperCase())))
                      .toList(),
                  onChanged: (value) => setStateSB(() => selectedType = value),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedPiece,
                  decoration: const InputDecoration(
                    labelText: "Sélectionner une pièce",
                    border: OutlineInputBorder(),
                  ),
                  items: accessiblePieces
                      .map((piece) => DropdownMenuItem<String>(
                          value: piece.id, child: Text(piece.nom)))
                      .toList(),
                  onChanged: (value) => setStateSB(() => selectedPiece = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler")),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final nom = nomController.text.trim();
                      if (nom.isEmpty ||
                          selectedType == null ||
                          selectedPiece == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Veuillez remplir tous les champs.")),
                        );
                        return;
                      }
                      setStateSB(() => isSubmitting = true);
                      try {
                        await _moduleService.addModule(Module(
                          id: '',
                          nom: nom,
                          type: selectedType!,
                          pieceId: selectedPiece!,
                          houseId: houseId,
                          userId: utilisateur.uid,
                        ));
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Appareil '$nom' ajouté avec succès ✅")),
                        );
                      } on ApiException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Erreur : ${e.message}")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Erreur : $e")),
                        );
                      } finally {
                        setStateSB(() => isSubmitting = false);
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text("Ajouter"),
            ),
          ],
        ),
      ),
    );
  }

}

// ---------------- DIALOGUE RECONNAISSANCE VOCALE ----------------
class VoiceRecognitionDialog extends StatefulWidget {
  final String message;
  const VoiceRecognitionDialog({Key? key, required this.message}) : super(key: key);

  @override
  _VoiceRecognitionDialogState createState() => _VoiceRecognitionDialogState();
}

class _VoiceRecognitionDialogState extends State<VoiceRecognitionDialog>
    with SingleTickerProviderStateMixin {
  final SpeechService _speechService = SpeechService();
  late AnimationController _controller;
  String _recognizedText = "";
  bool _isListening = false;
  String _selectedLang = "français";

  final Map<String, String> _locales = {
    'français': 'fr_FR',
    'anglais': 'en_US',
    'lingala': 'fr_FR',
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    try {
      _speech_service_stopSafe();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _speech_service_stopSafe() async {
    try {
      await _speechService.stopListening();
    } catch (_) {}
  }

  Future<void> _handleListen() async {
    setState(() {
      _isListening = true;
      _recognizedText = "🎤 Parlez maintenant...";
    });

    final localeId = _locales[_selectedLang] ?? 'fr_FR';
    try {
      final String phrase = await _speechService.listen(
        localeId: localeId,
        maxListenDuration: const Duration(seconds: 8),
        onPartial: (partial) {
          if (!mounted) return;
          setState(() {
            _recognizedText =
                partial.trim().isEmpty ? "🎤 Parlez maintenant..." : partial;
          });
        },
      );

      if (!mounted) return;
      setState(() {
        _recognizedText = phrase.trim().isEmpty ? "" : phrase;
        _isListening = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _recognizedText = "Erreur reconnaissance : ${e.toString()}";
        _isListening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("Reconnaissance vocale",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 12),
          DropdownButton<String>(
            value: _selectedLang,
            dropdownColor: Colors.grey[800],
            style: const TextStyle(color: Colors.white),
            onChanged: (v) => setState(() => _selectedLang = v!),
            items: _locales.keys
                .map((lang) =>
                    DropdownMenuItem(value: lang, child: Text(lang)))
                .toList(),
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Container(
              width: _isListening ? 100 : 80,
              height: _isListening ? 100 : 80,
              decoration: const BoxDecoration(
                  color: Colors.purpleAccent, shape: BoxShape.circle),
              child: Icon(_isListening ? Icons.hearing : Icons.mic,
                  color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 20),
          Text(_recognizedText,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () async {
                  await _speech_service_stopSafe();
                  Navigator.pop(context, null);
                },
                child: const Text("Annuler",
                    style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton.icon(
                icon: Icon(_isListening ? Icons.stop : Icons.mic),
                label: Text(_isListening ? "Arrêter" : "Démarrer"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                onPressed: _isListening
                    ? () async {
                        await _speech_service_stopSafe();
                        setState(() => _isListening = false);
                      }
                    : _handleListen,
              ),
              TextButton(
                onPressed: () async {
                  // Si l'écoute est encore en cours, on la stoppe proprement
                  // pour récupérer le texte reconnu jusqu'ici au lieu de
                  // pop avec une chaîne vide.
                  if (_isListening) {
                    await _speech_service_stopSafe();
                    if (!mounted) return;
                    setState(() => _isListening = false);
                  }
                  final text = _recognizedText.trim();
                  final isPlaceholder =
                      text == "🎤 Parlez maintenant..." ||
                          text.startsWith("Erreur reconnaissance");
                  Navigator.of(context).pop({
                    'text': isPlaceholder ? "" : text,
                    'language': _selectedLang,
                  });
                },
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

