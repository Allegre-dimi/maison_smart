/// Représente un module domotique (prise/compteur, lampe, climatisation, gaz,
/// assistant vocal). Côté Django, ces modules sont 5 entités séparées
/// (`compteur`, `gaz`, `clim`, `eclairage`, `assistant_vocal`) ; côté Flutter
/// on les unifie dans un seul modèle pour réutiliser le code existant.
class Module {
  final String id;
  final String pieceId;
  final String houseId;
  String userId;
  final String nom;

  /// Type unifié pour l'app : `compteur` | `prise` | `eclairage` | `lampe`
  /// | `clim` | `climatisation` | `gaz` | `assistant_vocal`.
  final String type;
  bool etat;
  dynamic valeur;
  double consommation; // kWh
  double courant; // A

  DateTime? createdAt;
  DateTime? updatedAt;

  /// Compat Firestore : conservé mais non utilisé côté Django.
  final List<String> allowedUserIds;
  final Map<String, String> permissions;

  // ---------------- CLIMATISATION ----------------
  double? temperature;            // = température actuelle (clim)
  double? temperatureCible;       // = consigne (clim)
  double? puissance;              // vitesse_ventilateur (clim)
  String? mode;                   // cool|heat|fan|dry|auto
  bool? isFavoris;
  bool? balayageVertical;
  bool? balayageHorizontal;
  bool? eclairage;
  bool? silence;
  double? mesureCourant;
  double? consommationActuelle;

  // ---------------- ECLAIRAGE ----------------
  int? intensite;                 // 0..100
  String? couleur;                // #RRGGBB

  // ---------------- GAZ ----------------
  double? poids;
  double? niveau;                 // = niveau_gaz (%)
  double? densiteGaz;
  double? temperatureGaz;
  bool? fuite;
  double? seuilAlerteGaz;

  // ---------------- COMPTEUR INTELLIGENT ----------------
  double? tension;                // V
  double? puissanceActive;        // W
  double? energieTotale;          // kWh
  double? coutParKwh;
  double? montantFacture;
  DateTime? dernierReleve;
  double? seuilConso;

  // ---------------- ASSISTANT VOCAL ----------------
  String? wakeWord;
  String? langue;
  String? derniereCommande;
  int? nbCommandes;

  /// Token d'API du module (Arduino).
  String? apiToken;

  Module({
    required this.id,
    required this.pieceId,
    required this.houseId,
    required this.userId,
    required this.nom,
    required this.type,
    this.etat = false,
    this.valeur,
    this.consommation = 0.0,
    this.courant = 0.0,
    this.createdAt,
    this.updatedAt,
    this.allowedUserIds = const [],
    this.permissions = const {},
    this.temperature,
    this.temperatureCible,
    this.puissance,
    this.mode,
    this.isFavoris,
    this.balayageVertical,
    this.balayageHorizontal,
    this.eclairage,
    this.silence,
    this.mesureCourant,
    this.consommationActuelle,
    this.intensite,
    this.couleur,
    this.poids,
    this.niveau,
    this.densiteGaz,
    this.temperatureGaz,
    this.fuite,
    this.seuilAlerteGaz,
    this.tension,
    this.puissanceActive,
    this.energieTotale,
    this.coutParKwh,
    this.montantFacture,
    this.dernierReleve,
    this.seuilConso,
    this.wakeWord,
    this.langue,
    this.derniereCommande,
    this.nbCommandes,
    this.apiToken,
  });

  Module copyWith({
    String? id,
    String? pieceId,
    String? houseId,
    String? userId,
    String? nom,
    String? type,
    bool? etat,
    dynamic valeur,
    double? consommation,
    double? courant,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? allowedUserIds,
    Map<String, String>? permissions,
    double? temperature,
    double? temperatureCible,
    double? puissance,
    String? mode,
    bool? isFavoris,
    bool? balayageVertical,
    bool? balayageHorizontal,
    bool? eclairage,
    bool? silence,
    double? mesureCourant,
    double? consommationActuelle,
    int? intensite,
    String? couleur,
    double? poids,
    double? niveau,
    double? densiteGaz,
    double? temperatureGaz,
    bool? fuite,
    double? seuilAlerteGaz,
    double? tension,
    double? puissanceActive,
    double? energieTotale,
    double? coutParKwh,
    double? montantFacture,
    DateTime? dernierReleve,
    double? seuilConso,
    String? wakeWord,
    String? langue,
    String? derniereCommande,
    int? nbCommandes,
    String? apiToken,
  }) {
    return Module(
      id: id ?? this.id,
      pieceId: pieceId ?? this.pieceId,
      houseId: houseId ?? this.houseId,
      userId: userId ?? this.userId,
      nom: nom ?? this.nom,
      type: type ?? this.type,
      etat: etat ?? this.etat,
      valeur: valeur ?? this.valeur,
      consommation: consommation ?? this.consommation,
      courant: courant ?? this.courant,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      allowedUserIds: allowedUserIds ?? this.allowedUserIds,
      permissions: permissions ?? this.permissions,
      temperature: temperature ?? this.temperature,
      temperatureCible: temperatureCible ?? this.temperatureCible,
      puissance: puissance ?? this.puissance,
      mode: mode ?? this.mode,
      isFavoris: isFavoris ?? this.isFavoris,
      balayageVertical: balayageVertical ?? this.balayageVertical,
      balayageHorizontal: balayageHorizontal ?? this.balayageHorizontal,
      eclairage: eclairage ?? this.eclairage,
      silence: silence ?? this.silence,
      mesureCourant: mesureCourant ?? this.mesureCourant,
      consommationActuelle: consommationActuelle ?? this.consommationActuelle,
      intensite: intensite ?? this.intensite,
      couleur: couleur ?? this.couleur,
      poids: poids ?? this.poids,
      niveau: niveau ?? this.niveau,
      densiteGaz: densiteGaz ?? this.densiteGaz,
      temperatureGaz: temperatureGaz ?? this.temperatureGaz,
      fuite: fuite ?? this.fuite,
      seuilAlerteGaz: seuilAlerteGaz ?? this.seuilAlerteGaz,
      tension: tension ?? this.tension,
      puissanceActive: puissanceActive ?? this.puissanceActive,
      energieTotale: energieTotale ?? this.energieTotale,
      coutParKwh: coutParKwh ?? this.coutParKwh,
      montantFacture: montantFacture ?? this.montantFacture,
      dernierReleve: dernierReleve ?? this.dernierReleve,
      seuilConso: seuilConso ?? this.seuilConso,
      wakeWord: wakeWord ?? this.wakeWord,
      langue: langue ?? this.langue,
      derniereCommande: derniereCommande ?? this.derniereCommande,
      nbCommandes: nbCommandes ?? this.nbCommandes,
      apiToken: apiToken ?? this.apiToken,
    );
  }

  /// Construit un Module à partir d'une réponse Django.
  ///
  /// Les modules de différents types ont des champs différents ; on lit
  /// tout ce qui est présent.
  factory Module.fromJson(Map<String, dynamic> data) {
    final type = (data['type'] ?? data['__type'] ?? '').toString();
    return Module(
      id: (data['id'] ?? '').toString(),
      pieceId: (data['piece'] ?? data['pieceId'] ?? data['piece_id'] ?? '').toString(),
      houseId: (data['maison'] ?? data['houseId'] ?? data['maison_id'] ?? '').toString(),
      userId: (data['user'] ?? data['userId'] ?? data['user_id'] ?? '').toString(),
      nom: data['nom'] ?? '',
      type: type,
      etat: data['etat'] ?? false,
      valeur: data['valeur'],
      consommation: _toDouble(data['consommation'], 0.0),
      courant: _toDouble(data['courant'], 0.0),
      createdAt: _parseDate(data['created_at'] ?? data['createdAt']),
      updatedAt: _parseDate(data['updated_at'] ?? data['updatedAt']),
      allowedUserIds: List<String>.from(
          (data['allowed_user_ids'] ?? data['allowedUserIds'] ?? const [])
              .map((e) => e.toString())),
      permissions:
          Map<String, String>.from(data['permissions'] ?? const <String, String>{}),
      // Clim
      temperature: _toDouble(data['temperature_actuelle'] ?? data['temperature'], null),
      temperatureCible: _toDouble(data['temperature_cible'], null),
      puissance: _toDouble(data['vitesse_ventilateur'] ?? data['puissance'], null),
      mode: data['mode'],
      isFavoris: data['isFavoris'] ?? data['is_favoris'],
      balayageVertical: data['balayageVertical'] ?? data['balayage_vertical'],
      balayageHorizontal: data['balayageHorizontal'] ?? data['balayage_horizontal'],
      eclairage: data['eclairage'],
      silence: data['silence'],
      mesureCourant: _toDouble(data['mesureCourant'] ?? data['mesure_courant'], null),
      consommationActuelle:
          _toDouble(data['consommationActuelle'] ?? data['consommation_actuelle'], null),
      // Eclairage
      intensite: data['intensite'] is int
          ? data['intensite'] as int
          : (data['intensite'] is num ? (data['intensite'] as num).toInt() : null),
      couleur: data['couleur'],
      // Gaz
      poids: _toDouble(data['poids'], null),
      niveau: _toDouble(data['niveau_gaz'] ?? data['niveau'], null),
      densiteGaz: _toDouble(data['densiteGaz'] ?? data['densite_gaz'], null),
      temperatureGaz: _toDouble(data['temperatureGaz'] ?? data['temperature_gaz'], null),
      fuite: data['fuite'],
      seuilAlerteGaz: _toDouble(data['seuil_alerte_gaz'] ?? data['seuilAlerteGaz'], null),
      // Compteur
      tension: _toDouble(data['tension'], null),
      puissanceActive: _toDouble(data['puissanceActive'] ?? data['puissance_active'], null),
      energieTotale: _toDouble(data['energieTotale'] ?? data['energie_totale'], null),
      coutParKwh: _toDouble(data['coutParKwh'] ?? data['cout_par_kwh'], null),
      montantFacture: _toDouble(data['montantFacture'] ?? data['montant_facture'], null),
      dernierReleve: _parseDate(data['dernier_releve'] ?? data['dernierReleve']),
      seuilConso: _toDouble(data['seuil_conso'] ?? data['seuilConso'], null),
      // Assistant vocal
      wakeWord: data['wake_word'] ?? data['wakeWord'],
      langue: data['langue'],
      derniereCommande: data['derniere_commande'] ?? data['derniereCommande'],
      nbCommandes: data['nb_commandes'] is int
          ? data['nb_commandes'] as int
          : (data['nb_commandes'] is num ? (data['nb_commandes'] as num).toInt() : null),
      apiToken: data['api_token'] ?? data['apiToken'],
    );
  }

  /// Alias pour rétro-compatibilité avec l'ancien code Firestore.
  factory Module.fromMap(Map<String, dynamic> data, String documentId) {
    final merged = Map<String, dynamic>.from(data);
    merged['id'] = documentId;
    return Module.fromJson(merged);
  }

  /// Endpoint Django de la collection en fonction du type unifié.
  /// Renvoie par ex. `compteurs`, `gaz`, `clims`, `eclairages`, `assistant_vocaux`.
  String get endpointCollection {
    switch (type.toLowerCase()) {
      case 'clim':
      case 'climatisation':
        return 'clims';
      case 'gaz':
        return 'gaz';
      case 'eclairage':
      case 'lampe':
      case 'lumiere':
      case 'lumière':
      case 'lumiére':
        return 'eclairages';
      case 'assistant_vocal':
      case 'assistant':
      case 'vocal':
        return 'assistant_vocaux';
      case 'compteur':
      case 'prise':
      default:
        return 'compteurs';
    }
  }

  /// Type de module pour les payloads (`module_type`).
  String get djangoType {
    switch (type.toLowerCase()) {
      case 'clim':
      case 'climatisation':
        return 'clim';
      case 'gaz':
        return 'gaz';
      case 'eclairage':
      case 'lampe':
      case 'lumiere':
      case 'lumière':
      case 'lumiére':
        return 'eclairage';
      case 'assistant_vocal':
      case 'assistant':
      case 'vocal':
        return 'assistant_vocal';
      case 'compteur':
      case 'prise':
      default:
        return 'compteur';
    }
  }

  /// Payload pour `POST /api/<collection>/` (création).
  Map<String, dynamic> toCreateJson() {
    final base = <String, dynamic>{
      'nom': nom,
      'piece': pieceId,
    };
    switch (djangoType) {
      case 'clim':
        if (temperatureCible != null) base['temperature_cible'] = temperatureCible;
        if (mode != null) base['mode'] = mode;
        if (puissance != null) base['vitesse_ventilateur'] = puissance!.toInt();
        break;
      case 'gaz':
        if (seuilAlerteGaz != null) base['seuil_alerte_gaz'] = seuilAlerteGaz;
        break;
      case 'eclairage':
        if (intensite != null) base['intensite'] = intensite;
        if (couleur != null) base['couleur'] = couleur;
        break;
      case 'assistant_vocal':
        if (wakeWord != null) base['wake_word'] = wakeWord;
        if (langue != null) base['langue'] = langue;
        break;
      case 'compteur':
        if (seuilConso != null) base['seuil_conso'] = seuilConso;
        break;
    }
    return base;
  }

  Map<String, dynamic> toMap() => toCreateJson();

  bool get isSwitchable => djangoType != 'gaz';

  static double _toDouble(dynamic v, double? def) {
    if (v == null) return def ?? 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? (def ?? 0.0);
    return def ?? 0.0;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
