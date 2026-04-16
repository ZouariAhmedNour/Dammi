import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userapp/api/storage_service.dart';

class ApiConfig {
  static const String baseUrl = 'http://192.168.1.105:8080/api';
}

class ApiClient {
  final StorageService storage;

  ApiClient(this.storage);

  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    return dio;
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.read(storageServiceProvider);
  return ApiClient(storage).dio;
});