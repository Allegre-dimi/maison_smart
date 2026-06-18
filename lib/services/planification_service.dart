import 'api_client.dart';

/// Une planification synchronisée avec le backend Django.
///
/// Correspond au `PlanificationSerializer` côté Django :
///   - POST/PUT envoient `module_type` + `module_id`
///   - GET reçoit `target_type` / `target_id` / `target_nom` (read-only)
class Planification {
  final int? id;
  final String moduleType;
  final String moduleId;
  final String? targetNom;
  final String nom;
  final Map<String, dynamic> commande;
  final DateTime dateExecution;
  final String recurrence; // 'none' | 'daily' | 'weekly'
  final String? recurrenceLabel;
  final bool isActive;
  final DateTime? nextRunAt;
  final DateTime? lastRunAt;
  final bool? lastRunOk;
  final String? lastRunMessage;

  Planification({
    this.id,
    required this.moduleType,
    required this.moduleId,
    this.targetNom,
    required this.nom,
    required this.commande,
    required this.dateExecution,
    this.recurrence = 'none',
    this.recurrenceLabel,
    this.isActive = true,
    this.nextRunAt,
    this.lastRunAt,
    this.lastRunOk,
    this.lastRunMessage,
  });

  factory Planification.fromJson(Map<String, dynamic> json) {
    DateTime? parseDt(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString()).toLocal();
      } catch (_) {
        return null;
      }
    }

    return Planification(
      id: json['id'] as int?,
      moduleType: (json['target_type'] ?? json['module_type'] ?? '').toString(),
      moduleId: (json['target_id'] ?? json['module_id'] ?? '').toString(),
      targetNom: json['target_nom'] as String?,
      nom: (json['nom'] ?? '') as String,
      commande: (json['commande'] is Map)
          ? Map<String, dynamic>.from(json['commande'] as Map)
          : <String, dynamic>{},
      dateExecution: parseDt(json['date_execution']) ?? DateTime.now(),
      recurrence: (json['recurrence'] ?? 'none') as String,
      recurrenceLabel: json['recurrence_label'] as String?,
      isActive: (json['is_active'] ?? true) == true,
      nextRunAt: parseDt(json['next_run_at']),
      lastRunAt: parseDt(json['last_run_at']),
      lastRunOk: json['last_run_ok'] as bool?,
      lastRunMessage: json['last_run_message'] as String?,
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'module_type': moduleType,
        'module_id': moduleId,
        'nom': nom,
        'commande': commande,
        'date_execution': dateExecution.toUtc().toIso8601String(),
        'recurrence': recurrence,
        'is_active': isActive,
      };
}

/// Client REST pour `/api/planifications/`.
///
/// Endpoints :
///   GET    /api/planifications/             — liste (filtrable ?module_id=...&module_type=...)
///   POST   /api/planifications/             — création
///   GET    /api/planifications/{id}/        — détail
///   PUT    /api/planifications/{id}/        — update
///   DELETE /api/planifications/{id}/        — suppression
///   POST   /api/planifications/{id}/toggle/ — bascule is_active (si l'action existe côté backend)
class PlanificationService {
  final ApiClient _api = ApiClient();

  /// Liste toutes les planifications. Peut filtrer par module.
  Future<List<Planification>> list({
    String? moduleType,
    String? moduleId,
  }) async {
    final query = <String, dynamic>{};
    if (moduleType != null) query['module_type'] = moduleType;
    if (moduleId != null) query['module_id'] = moduleId;

    final data = await _api.get(
      '/api/planifications/',
      query: query.isEmpty ? null : query,
    );
    final list = _results(data);
    return list
        .map((e) => Planification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Planification> get(int id) async {
    final data =
        await _api.get('/api/planifications/$id/') as Map<String, dynamic>;
    return Planification.fromJson(data);
  }

  Future<Planification> create(Planification p) async {
    final data = await _api.post('/api/planifications/', body: p.toCreateJson())
        as Map<String, dynamic>;
    return Planification.fromJson(data);
  }

  Future<Planification> update(
    int id, {
    String? nom,
    Map<String, dynamic>? commande,
    DateTime? dateExecution,
    String? recurrence,
    bool? isActive,
  }) async {
    final patch = <String, dynamic>{};
    if (nom != null) patch['nom'] = nom;
    if (commande != null) patch['commande'] = commande;
    if (dateExecution != null) {
      patch['date_execution'] = dateExecution.toUtc().toIso8601String();
    }
    if (recurrence != null) patch['recurrence'] = recurrence;
    if (isActive != null) patch['is_active'] = isActive;

    final data = await _api.put('/api/planifications/$id/', body: patch)
        as Map<String, dynamic>;
    return Planification.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _api.delete('/api/planifications/$id/');
  }

  /// Bascule rapidement is_active (utilise update si pas d'action dédiée).
  Future<Planification> setActive(int id, bool active) =>
      update(id, isActive: active);

  // ---------- helpers ----------

  List _results(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      if (data['results'] is List) return data['results'] as List;
    }
    return const [];
  }
}
