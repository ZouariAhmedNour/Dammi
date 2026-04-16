import 'package:userapp/models/app_user.dart';

class AuthResponse {
  final String token;
  final AppUser? user;

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

    AppUser? user;
    if (nestedUser is Map<String, dynamic>) {
      user = AppUser.fromJson(nestedUser);
    } else if (json.containsKey('email') ||
        json.containsKey('prenom') ||
        json.containsKey('nom')) {
      user = AppUser.fromJson(json);
    }

    return AuthResponse(
      token: token,
      user: user,
    );
  }
}