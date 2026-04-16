import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userapp/api/api_client.dart';
import 'package:userapp/models/donor_card_model.dart';

class DonorApi {
  final Dio _dio;

  DonorApi(this._dio);

  Future<DonorCardModel> getCardByUser(int userId) async {
    try {
      final response = await _dio.get('/cartes-donneur/user/$userId');

      return DonorCardModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message']?.toString() ??
            e.message ??
            'Erreur lors du chargement de la carte donneur',
      );
    }
  }
}

final donorApiProvider = Provider<DonorApi>((ref) {
  return DonorApi(ref.read(dioProvider));
});