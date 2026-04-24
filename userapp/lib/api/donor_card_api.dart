import 'package:dio/dio.dart';
import 'package:userapp/models/donor_card_model.dart';

class DonorCardApi {
  final Dio dio;

  DonorCardApi(this.dio);

  Future<bool> getAccessStatus(int userId) async {
    final res = await dio.get('/cartes-donneur/user/$userId/can-access');
    return res.data == true;
  }

  Future<DonorCard?> getCardByUser(int userId) async {
    try {
      final res = await dio.get('/cartes-donneur/user/$userId');
      return DonorCard.fromJson(res.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<DonorCard> generateCard(int userId) async {
    final res = await dio.post('/cartes-donneur/generer/$userId');
    return DonorCard.fromJson(res.data);
  }

  Future<DonorCard> getOrGenerateCard(int userId) async {
  final existing = await getCardByUser(userId);
  if (existing != null) return existing;

  await generateCard(userId);

  // 🔥 IMPORTANT : refetch après génération
  final newCard = await getCardByUser(userId);
  if (newCard == null) {
    throw Exception("Carte non récupérée après génération");
  }

  return newCard;
}
}