import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:userapp/api/api_client.dart';
import 'package:userapp/models/auth_response.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('AUTH API -> LOGIN START');
        debugPrint('email: ${email.trim()}');
      }

      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      if (kDebugMode) {
        debugPrint('AUTH API -> LOGIN SUCCESS');
        debugPrint('response raw: ${response.data}');
      }

      return AuthResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('AUTH API -> LOGIN ERROR');
        debugPrint(_extractMessage(e));
      }
      throw Exception(_extractMessage(e));
    } catch (_) {
      throw Exception('Erreur inattendue lors de la connexion');
    }
  }

  Future<AuthResponse> register({
    required String prenom,
    required String nom,
    required String email,
    required String password,
    required String phone,
    required String sexe,
    DateTime? lastDonation,
    required int typeSanguinId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'prenom': prenom.trim(),
        'nom': nom.trim(),
        'email': email.trim(),
        'password': password,
        'phone': phone.trim(),
        'sexe': sexe,
        'lastDonation': lastDonation != null
            ? DateFormat('yyyy-MM-dd').format(lastDonation)
            : null,
        'typeSanguinId': typeSanguinId,
      };

      if (kDebugMode) {
        debugPrint('AUTH API -> REGISTER START');
        debugPrint('payload: {');
        debugPrint('  prenom: ${payload['prenom']},');
        debugPrint('  nom: ${payload['nom']},');
        debugPrint('  email: ${payload['email']},');
        debugPrint('  phone: ${payload['phone']},');
        debugPrint('  sexe: ${payload['sexe']},');
        debugPrint('  lastDonation: ${payload['lastDonation']},');
        debugPrint('  typeSanguinId: ${payload['typeSanguinId']},');
        debugPrint('  typeSanguinAboGroup: ${payload['typeSanguinAboGroup']},');
        debugPrint('  password: ***');
        debugPrint('}');
      }

      final response = await _dio.post(
        '/auth/register',
        data: payload,
      );

      if (kDebugMode) {
        debugPrint('AUTH API -> REGISTER SUCCESS');
        debugPrint('response raw: ${response.data}');
      }

      return AuthResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('AUTH API -> REGISTER ERROR');
        debugPrint(_extractMessage(e));
      }
      throw Exception(_extractMessage(e));
    } catch (_) {
      throw Exception("Erreur inattendue lors de l'inscription");
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) {
        return data['message'].toString();
      }

      if (data['error'] != null) {
        return data['error'].toString();
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Délai de connexion dépassé';
      case DioExceptionType.sendTimeout:
        return "Délai d'envoi dépassé";
      case DioExceptionType.receiveTimeout:
        return 'Délai de réponse dépassé';
      case DioExceptionType.connectionError:
        return 'Impossible de se connecter au serveur';
      case DioExceptionType.badCertificate:
        return 'Certificat serveur invalide';
      case DioExceptionType.cancel:
        return 'Requête annulée';
      case DioExceptionType.unknown:
        return 'Erreur réseau inconnue';
      case DioExceptionType.badResponse:
        return 'Réponse serveur invalide';
    }
  }
}

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.read(dioProvider));
});