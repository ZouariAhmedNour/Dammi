import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userapp/api/api_client.dart';
import 'package:userapp/models/blood_type.dart';

class LookupApi {
  final Dio _dio;

  LookupApi(this._dio);

  Future<List<BloodType>> getBloodTypes() async {
    try {
      final response = await _dio.get('/types-sanguin');

      final data = response.data;
      if (data is List) {
        return data
            .map((e) => BloodType.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      throw Exception('Format inattendu pour les types sanguins');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Erreur lors du chargement des groupes');
    }
  }
}

final lookupApiProvider = Provider<LookupApi>((ref) {
  return LookupApi(ref.read(dioProvider));
});