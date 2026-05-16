import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import 'api_client.dart';

class ChatApi {
  final Dio dio;

  ChatApi(this.dio);

  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> history,
  }) async {
    final response = await dio
        .post(
          '/chat',
          data: {
            'message': message,
            'history': history.map((m) => m.toJson()).toList(),
          },
        )
        .timeout(const Duration(seconds: 60));

    final data = response.data as Map<String, dynamic>;
    return (data['answer'] ?? '').toString();
  }
}

final chatApiProvider = Provider<ChatApi>((ref) {
  final dio = ref.read(dioProvider);
  return ChatApi(dio);
});