import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userapp/api/api_client.dart';
import 'package:userapp/models/blood_request.dart';

class BloodRequestApi {
  final Dio _dio;

  BloodRequestApi(this._dio);

  Future<BloodRequest> createRequest({
    required int quantite,
    required bool urgence,
    required String contactNom,
    required String raisonDemande,
    required String notesComplementaires,
    required int userId,
    required int typeSanguinId,
  }) async {
    try {
      final response = await _dio.post(
        '/demandes',
        data: {
          'quantite': quantite,
          'urgence': urgence,
          'contactNom': contactNom,
          'raisonDemande': raisonDemande,
          'notesComplementaires': notesComplementaires,
          'userId': userId,
          'typeSanguinId': typeSanguinId,
        },
      );

      return BloodRequest.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Erreur création demande');
    }
  }

  Future<List<BloodRequest>> getUserRequests(int userId) async {
    try {
      final response = await _dio.get('/demandes/user/$userId');

      final data = response.data;

      return (data as List)
          .map((e) => BloodRequest.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Erreur historique');
    }
  }
}

final bloodRequestApiProvider = Provider<BloodRequestApi>((ref) {
  return BloodRequestApi(ref.read(dioProvider));
});