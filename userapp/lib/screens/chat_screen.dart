import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text;

    if (text.trim().isEmpty) return;

    _controller.clear();

    await ref.read(chatProvider.notifier).send(text);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildBubble(ChatMessage message) {
    final isUser = message.role == ChatRole.user;

    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isUser
              ? Colors.blueGrey.shade100
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              ref.read(chatProvider.notifier).clear();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: state.messages.isEmpty
                  ? const Center(
                      child: Text(
                        'Commence une conversation 👋',
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        return _buildBubble(
                          state.messages[index],
                        );
                      },
                    ),
            ),

            if (state.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Écris ton message...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),

                  const SizedBox(width: 8),

                  IconButton.filled(
                    onPressed:
                        state.loading ? null : _sendMessage,
                    icon: state.loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}