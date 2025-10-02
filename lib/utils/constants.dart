class AppConstants {
  // App Info
  static const String appName = 'VideoCall App';
  static const String appVersion = '1.0.0';
  
  // API Constants
  static const String baseUrl = 'https://reqres.in/api';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String usersCacheKey = 'cached_users';
  static const String authUserKey = 'auth_user';
  static const String lastFetchKey = 'last_users_fetch';
  
  // Default Values
  static const String defaultChannelName = 'test_channel';
  static const int defaultUserId = 0;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Colors
  static const int primaryColorValue = 0xFF2196F3;
  static const int accentColorValue = 0xFF03DAC6;
  static const int errorColorValue = 0xFFB00020;
  
  // Mock Credentials
  static const String mockEmail = 'test@example.com';
  static const String mockPassword = 'password';
}
