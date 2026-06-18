import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic body;
  ApiException(this.statusCode, this.message, [this.body]);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Client HTTP centralisé.
/// - Injecte automatiquement le Bearer JWT s'il est présent.
/// - Tente un refresh sur 401 puis rejoue la requête une seule fois.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _http = http.Client();
  final TokenStorage _tokens = TokenStorage();

  Uri _u(String path, [Map<String, dynamic>? query]) {
    final cleaned = path.startsWith('/') ? path : '/$path';
    final base = '${ApiConfig.httpBase}$cleaned';
    if (query == null || query.isEmpty) return Uri.parse(base);
    final qp = <String, String>{};
    query.forEach((k, v) {
      if (v == null) return;
      qp[k] = v.toString();
    });
    return Uri.parse(base).replace(queryParameters: qp);
  }

  Map<String, String> _headers({bool jsonBody = true}) {
    final h = <String, String>{
      'Accept': 'application/json',
    };
    if (jsonBody) h['Content-Type'] = 'application/json';
    final tok = _tokens.access;
    if (tok != null && tok.isNotEmpty) {
      h['Authorization'] = 'Bearer $tok';
    }
    return h;
  }

  /// Refresh manuel du token. Retourne true si OK.
  Future<bool> refresh() async {
    final r = _tokens.refresh;
    if (r == null || r.isEmpty) return false;
    try {
      final resp = await _http.post(
        _u('/api/auth/jwt/refresh'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'refresh': r}),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        await _tokens.save(
          access: data['access'] as String,
          refresh: (data['refresh'] as String?) ?? r,
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    dynamic body,
    bool retry = true,
  }) async {
    final uri = _u(path, query);
    final headers = _headers();
    http.Response resp;
    try {
      switch (method) {
        case 'GET':
          resp = await _http.get(uri, headers: headers);
          break;
        case 'POST':
          resp = await _http.post(uri, headers: headers, body: body == null ? null : jsonEncode(body));
          break;
        case 'PUT':
          resp = await _http.put(uri, headers: headers, body: body == null ? null : jsonEncode(body));
          break;
        case 'PATCH':
          resp = await _http.patch(uri, headers: headers, body: body == null ? null : jsonEncode(body));
          break;
        case 'DELETE':
          resp = await _http.delete(uri, headers: headers, body: body == null ? null : jsonEncode(body));
          break;
        default:
          throw ArgumentError('Méthode HTTP non supportée: $method');
      }
    } on http.ClientException catch (e) {
      throw ApiException(0, 'Erreur réseau: ${e.message}');
    } on TimeoutException {
      throw ApiException(0, 'Délai d\'attente dépassé');
    }

    if (resp.statusCode == 401 && retry) {
      final ok = await refresh();
      if (ok) {
        return _send(method, path, query: query, body: body, retry: false);
      }
    }

    final txt = resp.body;
    dynamic decoded;
    if (txt.isNotEmpty) {
      try {
        decoded = jsonDecode(txt);
      } catch (_) {
        decoded = txt;
      }
    }

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return decoded;
    }

    String msg;
    if (decoded is Map<String, dynamic>) {
      msg = (decoded['detail'] ??
              decoded['error'] ??
              decoded['message'] ??
              decoded.toString())
          .toString();
    } else if (decoded is String) {
      msg = decoded;
    } else {
      msg = 'Erreur HTTP ${resp.statusCode}';
    }
    throw ApiException(resp.statusCode, msg, decoded);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, {dynamic body, Map<String, dynamic>? query}) =>
      _send('POST', path, body: body, query: query);

  Future<dynamic> put(String path, {dynamic body}) => _send('PUT', path, body: body);
  Future<dynamic> patch(String path, {dynamic body}) => _send('PATCH', path, body: body);
  Future<dynamic> delete(String path, {dynamic body}) =>
      _send('DELETE', path, body: body);
}
