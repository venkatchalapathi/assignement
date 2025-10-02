import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'https://reqres.in/api';
  static const Duration timeout = Duration(seconds: 30);

  // Mock authentication - in real app, this would be a proper login endpoint
  static Future<Map<String, dynamic>> login(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock validation
    if (email == 'test@example.com' && password == 'password') {
      return {
        'success': true,
        'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': 1,
          'email': email,
          'first_name': 'Test',
          'last_name': 'User',
          'avatar': 'https://reqres.in/img/faces/1-image.jpg',
        }
      };
    } else {
      throw Exception('Invalid credentials');
    }
  }

  // Fetch users from ReqRes API
  static Future<List<User>> getUsers({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users?page=$page'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> usersData = data['data'] ?? [];
        return usersData.map((userData) => User.fromJson(userData)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get user details by ID
  static Future<User> getUserById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data['data']);
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
