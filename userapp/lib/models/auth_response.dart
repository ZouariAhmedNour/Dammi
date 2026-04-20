import 'package:userapp/models/user.dart';

class AuthResponse {
  final String token;
  final User? user;

  const AuthResponse({
    required this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final token = (json['token'] ??
            json['accessToken'] ??
            json['access_token'] ??
            json['jwt'] ??
            '')
        .toString();

    final dynamic nestedUser =
        json['user'] ?? json['utilisateur'] ?? json['data']?['user'];

    User? user;
    if (nestedUser is Map<String, dynamic>) {
      user = User.fromJson(nestedUser);
    } else if (json.containsKey('email') ||
        json.containsKey('prenom') ||
        json.containsKey('nom')) {
      user = User.fromJson(json);
    }

    return AuthResponse(
      token: token,
      user: user,
    );
  }
}