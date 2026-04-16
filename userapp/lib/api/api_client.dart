import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userapp/api/storage_service.dart';

class ApiConfig {
  static const String baseUrl = 'https://192.168.1.105:8443/api';
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

    if (kDebugMode) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();

          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) {
            debugPrint('SSL CERT ACCEPTED IN DEBUG -> host: $host, port: $port');
            return true;
          };

          return client;
        },
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          debugPrint('REQUEST => ${options.method} ${options.uri}');
          debugPrint('HEADERS => ${options.headers}');
          debugPrint('BODY => ${options.data}');

          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('RESPONSE => ${response.statusCode} ${response.requestOptions.uri}');
          debugPrint('DATA => ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('ERROR => ${error.requestOptions.method} ${error.requestOptions.uri}');
          debugPrint('ERROR TYPE => ${error.type}');
          debugPrint('ERROR MESSAGE => ${error.message}');
          debugPrint('ERROR RESPONSE => ${error.response?.data}');
          handler.next(error);
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