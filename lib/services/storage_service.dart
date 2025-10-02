import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/auth_user.dart';

class StorageService {
  static const String _usersKey = 'cached_users';
  static const String _authUserKey = 'auth_user';
  static const String _lastFetchKey = 'last_users_fetch';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User caching methods
  static Future<void> cacheUsers(List<User> users) async {
    if (_prefs == null) await init();
    
    final usersJson = users.map((user) => user.toJson()).toList();
    await _prefs!.setString(_usersKey, json.encode(usersJson));
    await _prefs!.setString(_lastFetchKey, DateTime.now().toIso8601String());
  }

  static Future<List<User>> getCachedUsers() async {
    if (_prefs == null) await init();
    
    final usersJson = _prefs!.getString(_usersKey);
    if (usersJson != null) {
      final List<dynamic> usersData = json.decode(usersJson);
      return usersData.map((userData) => User.fromJson(userData)).toList();
    }
    return [];
  }

  static Future<bool> isUsersCacheValid({Duration maxAge = const Duration(hours: 1)}) async {
    if (_prefs == null) await init();
    
    final lastFetchString = _prefs!.getString(_lastFetchKey);
    if (lastFetchString == null) return false;
    
    final lastFetch = DateTime.parse(lastFetchString);
    return DateTime.now().difference(lastFetch) < maxAge;
  }

  static Future<void> clearUsersCache() async {
    if (_prefs == null) await init();
    await _prefs!.remove(_usersKey);
    await _prefs!.remove(_lastFetchKey);
  }

  // Auth user methods
  static Future<void> saveAuthUser(AuthUser user) async {
    if (_prefs == null) await init();
    await _prefs!.setString(_authUserKey, json.encode(user.toJson()));
  }

  static Future<AuthUser?> getAuthUser() async {
    if (_prefs == null) await init();
    
    final userJson = _prefs!.getString(_authUserKey);
    if (userJson != null) {
      return AuthUser.fromJson(json.decode(userJson));
    }
    return null;
  }

  static Future<void> clearAuthUser() async {
    if (_prefs == null) await init();
    await _prefs!.remove(_authUserKey);
  }

  // General storage methods
  static Future<void> setString(String key, String value) async {
    if (_prefs == null) await init();
    await _prefs!.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    if (_prefs == null) await init();
    return _prefs!.getString(key);
  }

  static Future<void> remove(String key) async {
    if (_prefs == null) await init();
    await _prefs!.remove(key);
  }
}
