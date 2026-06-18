import '../models/module.dart';
import 'api_client.dart';

/// Service unifié pour les 5 types de modules Django :
/// `compteur`, `gaz`, `clim`, `eclairage`, `assistant_vocal`.
///
/// Chaque type a sa propre collection :
///   GET/POST   /api/{collection}/
///   GET/PUT/DELETE /api/{collection}/{id}/
///   POST       /api/{collection}/{id}/commande   (action: on/off/toggle/set + payload)
///   POST       /api/{collection}/{id}/releve     (Arduino — non utilisé par l'app)
///
/// L'application Flutter manipule un objet `Module` unifié.
class ModuleService {
  final ApiClient _api = ApiClient();

  static const _collections = <String>[
    'compteurs',
    'gaz',
    'clims',
    'eclairages',
    'assistant_vocaux',
  ];

  /// Récupère TOUS les modules d'une maison (tous types confondus).
  Future<List<Module>> getModulesByMaison(String houseId, {String? type}) async {
    final data = await _api.get('/api/maisons/$houseId/modules',
        query: type == null ? null : {'type': type});
    final list = _results(data);
    return list.map((e) => Module.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Récupère les modules d'une pièce — agrège les 5 collections.
  Future<List<Module>> getModulesByPieceId(String pieceId) async {
    final futures = _collections.map((c) async {
      final data = await _api.get('/api/$c/', query: {'piece': pieceId});
      final list = _results(data);
      return list.map((e) {
        final map = Map<String, dynamic>.from(e as Map<String, dynamic>);
        map['type'] = map['type'] ?? _typeFromCollection(c);
        return Module.fromJson(map);
      });
    }).toList();
    final all = <Module>[];
    for (final f in futures) {
      all.addAll(await f);
    }
    return all;
  }

  /// Récupère un module par son id et son type.
  Future<Module?> getModule(String moduleId, {required String type}) async {
    final col = _collectionFromType(type);
    try {
      final data = await _api.get('/api/$col/$moduleId/') as Map<String, dynamic>;
      data['type'] = data['type'] ?? _typeFromCollection(col);
      return Module.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Recherche fuzzy par nom (insensible à la casse) dans une maison.
  /// Renvoie les modules dont le nom contient ou est contenu dans `rawName`.
  Future<List<Module>> findModulesByNameLoose(String rawName,
      {String? houseId, String? userId}) async {
    final target = rawName.trim().toLowerCase();
    if (target.isEmpty || houseId == null) return [];
    final all = await getModulesByMaison(houseId);
    return all.where((m) {
      final n = m.nom.toLowerCase();
      return n == target || n.contains(target) || target.contains(n);
    }).toList();
  }

  /// Récupère le premier module dont le nom matche exactement.
  Future<Module?> getModuleByNom(String nom, {String? houseId}) async {
    if (houseId == null) return null;
    final all = await getModulesByMaison(houseId);
    final lower = nom.toLowerCase();
    for (final m in all) {
      if (m.nom.toLowerCase() == lower) return m;
    }
    return null;
  }

  /// Crée un module. Le type doit être renseigné dans `module.type`.
  Future<Module> addModule(Module module) async {
    final col = module.endpointCollection;
    final body = module.toCreateJson();
    final data = await _api.post('/api/$col/', body: body) as Map<String, dynamic>;
    data['type'] = data['type'] ?? module.djangoType;
    return Module.fromJson(data);
  }

  /// Met à jour l'état ON/OFF via l'endpoint `commande`.
  Future<Module> setEtat(String moduleId, bool newEtat, {required String type}) async {
    return commande(moduleId, action: newEtat ? 'on' : 'off', type: type);
  }

  /// Envoie une commande (`on` / `off` / `toggle` / `set` avec payload).
  Future<Module> commande(
    String moduleId, {
    required String action,
    required String type,
    Map<String, dynamic>? payload,
  }) async {
    final col = _collectionFromType(type);
    final body = <String, dynamic>{'action': action};
    if (payload != null) body.addAll(payload);
    final data = await _api.post('/api/$col/$moduleId/commande/', body: body)
        as Map<String, dynamic>;
    // Le backend peut renvoyer `{ok, module_id, etat, result}` ou directement
    // le module mis à jour : on re-fetch pour être sûr d'avoir tout l'objet.
    if (data['module'] is Map<String, dynamic>) {
      final mod = Map<String, dynamic>.from(data['module'] as Map<String, dynamic>);
      mod['type'] = mod['type'] ?? _typeFromCollection(col);
      return Module.fromJson(mod);
    }
    final fresh = await getModule(moduleId, type: type);
    if (fresh != null) return fresh;
    final fallback = Map<String, dynamic>.from(data);
    fallback['id'] = moduleId;
    fallback['type'] = _typeFromCollection(col);
    return Module.fromJson(fallback);
  }

  Future<Module> updateModule(String moduleId,
      {required String type, required Map<String, dynamic> patch}) async {
    final col = _collectionFromType(type);
    final data =
        await _api.put('/api/$col/$moduleId/', body: patch) as Map<String, dynamic>;
    data['type'] = data['type'] ?? _typeFromCollection(col);
    return Module.fromJson(data);
  }

  Future<void> deleteModule(String moduleId, {required String type}) async {
    final col = _collectionFromType(type);
    await _api.delete('/api/$col/$moduleId/');
  }

  // ---------- helpers ----------

  String _collectionFromType(String type) {
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

  String _typeFromCollection(String col) {
    switch (col) {
      case 'clims':
        return 'clim';
      case 'gaz':
        return 'gaz';
      case 'eclairages':
        return 'eclairage';
      case 'assistant_vocaux':
        return 'assistant_vocal';
      case 'compteurs':
      default:
        return 'compteur';
    }
  }

  List _results(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      if (data['results'] is List) return data['results'] as List;
    }
    return const [];
  }
}
