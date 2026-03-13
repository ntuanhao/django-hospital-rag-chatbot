# chatbot/views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .agent import HospitalAgent
import json
import logging

logger = logging.getLogger(__name__)

# Khởi tạo Agent 1 lần duy nhất để tối ưu bộ nhớ
try:
    bot_agent = HospitalAgent()
except Exception as e:
    logger.error(f"Lỗi khởi tạo Chatbot Agent: {e}")
    bot_agent = None

class ChatbotView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        if not bot_agent:
             return Response({"error": "Chatbot chưa sẵn sàng."}, status=503)

        query = request.data.get('message', '')
        if not query:
            return Response({"error": "Vui lòng nhập nội dung tin nhắn."}, status=400)

        # Lấy thông tin người dùng để cá nhân hóa
        user = request.user
        user_context = f"Tên: {user.get_full_name()}"
        
        # Nếu là bệnh nhân, lấy thêm tiền sử bệnh
        if user.role == 'PATIENT' and hasattr(user, 'patient_profile'):
            profile = user.patient_profile
            if profile.medical_history:
                user_context += f", Tiền sử: {profile.medical_history}"
            if profile.allergies:
                user_context += f", Dị ứng: {profile.allergies}"

        try:
            # Gọi AI xử lý
            ai_response_str = bot_agent.ask(query, user_context)
            
            # Parse string thành JSON object
            ai_response_json = json.loads(ai_response_str)
            
            return Response(ai_response_json)
        
        except json.JSONDecodeError:
            # Fallback nếu AI không trả về đúng JSON
            return Response({
                "answer_text": ai_response_str, # Trả về text thô
                "suggested_actions": []
            })
        except Exception as e:
            logger.error(f"Chatbot Error: {e}")
            return Response({"error": "Có lỗi xảy ra khi xử lý tin nhắn."}, status=500)