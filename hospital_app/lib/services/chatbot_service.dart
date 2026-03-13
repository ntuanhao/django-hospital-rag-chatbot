// lib/services/chatbot_service.dart

class ChatbotService {
  // Hàm này sẽ được thay thế bằng lời gọi API thật trong tương lai
  Future<String> ask(String message) async {
    // Giả lập độ trễ mạng để có cảm giác chân thực
    await Future.delayed(const Duration(milliseconds: 1200));

    final lowerCaseMessage = message.toLowerCase().trim();

    if (lowerCaseMessage.contains('đặt lịch')) {
      return 'Để đặt lịch, bạn có thể vào mục "Đặt lịch" ở màn hình chính và làm theo hướng dẫn. Bạn muốn đặt lịch với bác sĩ nào cụ thể không?';
    } else if (lowerCaseMessage.contains('kết quả khám')) {
      return 'Bạn có thể xem lại toàn bộ lịch sử khám bệnh và đơn thuốc trong mục "Kết quả khám" tại trang chủ.';
    } else if (lowerCaseMessage.contains('đau đầu') || lowerCaseMessage.contains('nhức đầu')) {
      return 'Dựa trên triệu chứng đau đầu, bạn có thể cân nhắc khám chuyên khoa Nội thần kinh. Bạn có muốn xem danh sách các bác sĩ thuộc khoa này không?';
    } else if (lowerCaseMessage.contains('chào') || lowerCaseMessage.contains('hello')) {
      return 'Xin chào! Tôi là trợ lý ảo của phòng khám. Tôi có thể giúp gì cho bạn?';
    } else {
      return 'Xin lỗi, tôi chưa hiểu câu hỏi của bạn. Bạn có thể thử hỏi về "cách đặt lịch", "xem kết quả khám", hoặc mô tả triệu chứng như "đau đầu".';
    }
  }
}