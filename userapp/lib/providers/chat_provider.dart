import 'package:flutter_riverpod/legacy.dart';
import '../api/chat_api.dart';
import '../models/chat_message.dart';

final chatProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final api = ref.read(chatApiProvider);
  return ChatNotifier(api);
});

class ChatState {
  final List<ChatMessage> messages;
  final bool loading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.loading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? loading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatApi api;

  ChatNotifier(this.api) : super(const ChatState());

  Future<void> send(String text) async {
    final trimmed = text.trim();

    if (trimmed.isEmpty) return;

    final previousHistory = List<ChatMessage>.from(state.messages);

    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          role: ChatRole.user,
          text: trimmed,
        ),
      ],
      loading: true,
      error: null,
    );

    try {
      final answer = await api.sendMessage(
        message: trimmed,
        history: previousHistory,
      );

      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            role: ChatRole.assistant,
            text: answer,
          ),
        ],
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  void clear() {
    state = const ChatState();
  }
}