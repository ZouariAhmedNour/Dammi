enum ChatRole { user, assistant }

class ChatMessage {
  final ChatRole role;
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.role,
    required this.text,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'role': role == ChatRole.user ? 'user' : 'assistant',
      'content': text,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final role = (json['role'] ?? 'user').toString().toLowerCase();
    return ChatMessage(
      role: role == 'assistant' ? ChatRole.assistant : ChatRole.user,
      text: (json['content'] ?? '').toString(),
    );
  }
}