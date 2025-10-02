class AuthUser {
  final String email;
  final String password;
  final String? token;
  final DateTime? lastLogin;

  AuthUser({
    required this.email,
    required this.password,
    this.token,
    this.lastLogin,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      token: json['token'],
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'token': token,
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  AuthUser copyWith({
    String? email,
    String? password,
    String? token,
    DateTime? lastLogin,
  }) {
    return AuthUser(
      email: email ?? this.email,
      password: password ?? this.password,
      token: token ?? this.token,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
