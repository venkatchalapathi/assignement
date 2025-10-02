import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class UsersProvider with ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOffline = false;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;

  UsersProvider() {
    _loadCachedUsers();
  }

  Future<void> _loadCachedUsers() async {
    _users = await StorageService.getCachedUsers();
    notifyListeners();
  }

  Future<void> fetchUsers({bool forceRefresh = false}) async {
    if (!forceRefresh && _users.isNotEmpty && await StorageService.isUsersCacheValid()) {
      return;
    }

    _setLoading(true);
    _clearError();
    _isOffline = false;

    try {
      final fetchedUsers = await ApiService.getUsers();
      _users = fetchedUsers;
      await StorageService.cacheUsers(_users);
    } catch (e) {
      _setError(e.toString());
      _isOffline = true;
      
      // Try to load from cache if network fails
      if (_users.isEmpty) {
        _users = await StorageService.getCachedUsers();
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshUsers() async {
    await fetchUsers(forceRefresh: true);
  }

  Future<User?> getUserById(int id) async {
    try {
      return await ApiService.getUserById(id);
    } catch (e) {
      // Return from local cache if available
      return _users.firstWhere(
        (user) => user.id == id,
        orElse: () => throw Exception('User not found'),
      );
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
