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
  required String contactTelephone,
  required String raisonDemande,
  required String notesComplementaires,
  required int userId,
  required int pointCollecteId,
  required int? typeSanguinId,
  }) async {
    try {
      final response = await _dio.post(
        '/demandes',
        data: {
          'quantite': quantite,
          'urgence': urgence,
          'contactNom': contactNom,
          'contactTelephone': contactTelephone,
          'raisonDemande': raisonDemande,
          'notesComplementaires': notesComplementaires,
          'userId': userId,
          'pointCollecteId': pointCollecteId,
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

  Future<List<BloodRequest>> getUrgentRequests() async {
  try {
    final response = await _dio.get('/demandes/publiques/urgentes');

    final data = response.data;

    return (data as List)
        .map((e) => BloodRequest.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  } on DioException catch (e) {
    throw Exception(e.message ?? 'Erreur chargement demandes urgentes');
  }
}

Future<List<BloodRequest>> getAllRequests() async {
  try {
    final response = await _dio.get('/demandes');

    final data = response.data;

    return (data as List)
        .map(
          (e) => BloodRequest.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  } on DioException catch (e) {
    throw Exception(
      e.message ?? 'Erreur chargement demandes',
    );
  }
}

Future<Map<String, dynamic>> contribuerAUneDemande({
  required int demandeId,
  required int userId,
}) async {
  try {
    final response = await _dio.post(
      '/demandes/$demandeId/contribuer',
      data: {
        'userId': userId,
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  } on DioException catch (e) {
    throw Exception(e.message ?? 'Erreur lors de la contribution');
  }
}


}

final bloodRequestApiProvider = Provider<BloodRequestApi>((ref) {
  return BloodRequestApi(ref.read(dioProvider));
});