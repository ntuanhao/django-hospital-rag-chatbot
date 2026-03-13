// lib/screens/patient/chatbot_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/chat_message.dart';
import 'package:hospital_app/providers/chatbot_provider.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    
    ref.read(chatbotProvider.notifier).sendMessage(_textController.text);
    _textController.clear();
    
    // Tự động cuộn xuống tin nhắn mới nhất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe danh sách tin nhắn từ provider
    final messages = ref.watch(chatbotProvider);
    
    // Tự động cuộn khi có tin nhắn mới từ bot
    ref.listen(chatbotProvider, (_, __) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trợ lý AI'),
      ),
      body: Column(
        children: [
          // --- KHU VỰC HIỂN THỊ TIN NHẮN ---
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _ChatMessageBubble(message: message);
              },
            ),
          ),
          
          // --- KHU VỰC NHẬP LIỆU ---
          _ChatInputField(
            controller: _textController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

// ============== WIDGET BONG BÓNG CHAT ==============
class _ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isFromUser = message.author == ChatAuthor.user;
    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isFromUser ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: isFromUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isFromUser ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isFromUser ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// ============== WIDGET Ô NHẬP LIỆU ==============
class _ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInputField({required this.controller, required this.onSend});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  border: InputBorder.none,
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => onSend(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: onSend,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}