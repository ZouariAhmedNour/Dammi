import 'package:dio/dio.dart';

class UserApi {
  final Dio dio;

  UserApi(this.dio);

  Future<bool> updateStatutPertinent(int userId, bool value) async {
    final response = await dio.patch(
      '/users/$userId/statut',
      queryParameters: {
        'value': value,
      },
    );

    return response.data as bool;
  }
}