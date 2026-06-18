import 'package:shared_preferences/shared_preferences.dart';

/// Stockage local des jetons JWT (access + refresh) et de l'id utilisateur.
class TokenStorage {
  static const String _kAccess = 'auth_access_token';
  static const String _kRefresh = 'auth_refresh_token';
  static const String _kUserId = 'auth_user_id';
  static const String _kActiveHouseId = 'auth_active_house_id';

  static final TokenStorage _instance = TokenStorage._internal();
  factory TokenStorage() => _instance;
  TokenStorage._internal();

  String? _access;
  String? _refresh;
  String? _userId;
  String? _activeHouseId;

  String? get access => _access;
  String? get refresh => _refresh;
  String? get userId => _userId;
  String? get activeHouseId => _activeHouseId;

  bool get hasSession => _access != null && _access!.isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _access = prefs.getString(_kAccess);
    _refresh = prefs.getString(_kRefresh);
    _userId = prefs.getString(_kUserId);
    _activeHouseId = prefs.getString(_kActiveHouseId);
  }

  Future<void> save({
    required String access,
    required String refresh,
    String? userId,
  }) async {
    _access = access;
    _refresh = refresh;
    if (userId != null) _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccess, access);
    await prefs.setString(_kRefresh, refresh);
    if (userId != null) await prefs.setString(_kUserId, userId);
  }

  Future<void> setActiveHouseId(String? houseId) async {
    _activeHouseId = houseId;
    final prefs = await SharedPreferences.getInstance();
    if (houseId == null) {
      await prefs.remove(_kActiveHouseId);
    } else {
      await prefs.setString(_kActiveHouseId, houseId);
    }
  }

  Future<void> clear() async {
    _access = null;
    _refresh = null;
    _userId = null;
    _activeHouseId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccess);
    await prefs.remove(_kRefresh);
    await prefs.remove(_kUserId);
    await prefs.remove(_kActiveHouseId);
  }
}
