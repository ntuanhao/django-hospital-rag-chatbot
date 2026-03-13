// lib/models/chat_message.dart

// Enum để phân biệt người gửi là User hay Bot
enum ChatAuthor { user, bot }

class ChatMessage {
  final String text;
  final ChatAuthor author;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.author,
    required this.timestamp,
  });
}