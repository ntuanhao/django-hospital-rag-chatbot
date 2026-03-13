# chatbot/agent.py
import os
import json
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.prompts import PromptTemplate
from .rag_service import RAGService
from .tools import get_service_info_tool

# Load API Key
GOOGLE_API_KEY = os.environ.get('GOOGLE_API_KEY')

class HospitalAgent:
    def __init__(self):
        self.llm = ChatGoogleGenerativeAI(
            model="gemini-1.5-flash", # Dùng bản Flash cho nhanh và rẻ
            google_api_key=GOOGLE_API_KEY,
            temperature=0.3 # Độ sáng tạo thấp để trả lời chính xác
        )
        self.rag = RAGService.get_instance()

    def ask(self, user_query, user_context=""):
        # 1. Lấy kiến thức từ RAG
        retrieved_knowledge = self.rag.search(user_query)

        # 2. Tự động kiểm tra xem User có hỏi về giá dịch vụ không
        service_info = ""
        if "giá" in user_query.lower() or "bao nhiêu tiền" in user_query.lower() or "chi phí" in user_query.lower():
            # Lấy keyword từ query (đây là cách đơn giản, nâng cao dùng LLM extract entity)
            service_info = get_service_info_tool(user_query)

        # 3. Xây dựng Prompt
        prompt_template = """
        VAI TRÒ: Bạn là Trợ lý Y tế ảo (AI Receptionist) của Bệnh viện.
        NHIỆM VỤ: Hỗ trợ bệnh nhân giải đáp thắc mắc, báo giá dịch vụ và hướng dẫn đặt lịch.

        NGUYÊN TẮC AN TOÀN (QUAN TRỌNG):
        1. KHÔNG bao giờ tự chẩn đoán bệnh khẳng định (VD: "Bạn bị ung thư"). Chỉ nói "Có khả năng..." hoặc "Triệu chứng gợi ý...".
        2. Luôn khuyên người dùng đi khám bác sĩ thực tế.
        3. Nếu tình huống khẩn cấp (khó thở, đau tim, ngất), yêu cầu gọi cấp cứu ngay.

        DỮ LIỆU NGỮ CẢNH:
        - Thông tin người dùng: {user_context}
        - Kiến thức Y khoa tra cứu: {knowledge}
        - Thông tin Dịch vụ/Giá (nếu có): {service_info}

        YÊU CẦU ĐẦU RA (BẮT BUỘC ĐỊNH DẠNG JSON):
        Trả về JSON thuần túy, không có markdown (```json).
        Cấu trúc:
        {{
            "answer_text": "Câu trả lời thân thiện bằng tiếng Việt, có sử dụng emoji y tế...",
            "suggested_actions": [
                {{
                    "type": "VIEW_SERVICE", 
                    "payload": {{ "keyword": "tên dịch vụ user quan tâm" }} 
                }},
                {{
                    "type": "BOOK_APPOINTMENT",
                    "label": "Đặt lịch ngay"
                }}
            ]
        }}
        Lưu ý: 
        - Chỉ trả về "type": "VIEW_SERVICE" nếu câu trả lời có nhắc đến một dịch vụ cụ thể có giá tiền.
        - Luôn trả về "type": "BOOK_APPOINTMENT" nếu người dùng có ý định đi khám.

        CÂU HỎI CỦA NGƯỜI DÙNG: {query}
        """
        
        prompt = PromptTemplate.from_template(prompt_template)
        chain = prompt | self.llm

        # 4. Gọi AI
        response = chain.invoke({
            "user_context": user_context,
            "knowledge": retrieved_knowledge,
            "service_info": service_info,
            "query": user_query
        })

        # 5. Xử lý text trả về để đảm bảo là JSON
        content = response.content.strip()
        # Xóa markdown nếu Gemini lỡ thêm vào
        if content.startswith("```json"):
            content = content[7:]
        if content.endswith("```"):
            content = content[:-3]
        
        return content