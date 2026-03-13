// lib/providers/chatbot_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/chat_message.dart';
import 'package:hospital_app/services/chatbot_service.dart';

// Provider cho Service
final chatbotServiceProvider = Provider((ref) => ChatbotService());

// Provider chính quản lý danh sách tin nhắn
final chatbotProvider =
    NotifierProvider.autoDispose<ChatbotNotifier, List<ChatMessage>>(
        ChatbotNotifier.new); // SỬA Ở ĐÂY

class ChatbotNotifier extends Notifier<List<ChatMessage>> {
  // KHÔNG CẦN constructor và `_ref` nữa

  @override
  List<ChatMessage> build() {
    // 1. Thêm phương thức build() để trả về state ban đầu
    return [];
  }

  // Hàm để gửi tin nhắn
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Thêm tin nhắn của người dùng vào danh sách
    final userMessage = ChatMessage(
      text: text,
      author: ChatAuthor.user,
      timestamp: DateTime.now(),
    );
    state = [...state, userMessage];

    // 2. Gọi service để lấy câu trả lời của bot
    try {
      // 2. Dùng `ref.read` (biến `ref` có sẵn trong Notifier)
      final botReplyText = await ref.read(chatbotServiceProvider).ask(text);
      final botMessage = ChatMessage(
        text: botReplyText,
        author: ChatAuthor.bot,
        timestamp: DateTime.now(),
      );
      // 3. Thêm tin nhắn của bot vào danh sách
      state = [...state, botMessage];
    } catch (e) {
      // Xử lý nếu có lỗi
      final errorMessage = ChatMessage(
        text: 'Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại sau.',
        author: ChatAuthor.bot,
        timestamp: DateTime.now(),
      );
      state = [...state, errorMessage];
    }
  }
}