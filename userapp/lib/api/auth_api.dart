import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userapp/api/api_client.dart';
import 'package:userapp/models/auth_response.dart';
import 'package:userapp/models/blood_type.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
    BloodType? bloodType,
  }) async {
    try {
      final (prenom, nom) = _splitFullName(fullName);

      final payload = <String, dynamic>{
        'prenom': prenom,
        'nom': nom,
        'email': email,
        'password': password,
      };

      // IMPORTANT :
      // Comme tu ne m'as pas encore donné la classe RegisterRequest exacte,
      // je n'envoie PAS le groupe sanguin ici pour éviter un 400.
      // Quand tu m'enverras RegisterRequest, je te brancherai ça exactement.

      final response = await _dio.post(
        '/auth/register',
        data: payload,
      );

      return AuthResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  (String, String) _splitFullName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return ('Utilisateur', 'Dammi');
    }
    if (parts.length == 1) {
      return (parts.first, 'Dammi');
    }
    return (parts.first, parts.sublist(1).join(' '));
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    if (data is Map && data['error'] != null) {
      return data['error'].toString();
    }

    return e.message ?? 'Une erreur réseau est survenue';
  }
}

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.read(dioProvider));
});