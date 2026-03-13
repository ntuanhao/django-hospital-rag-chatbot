# chatbot/rag_service.py
import chromadb
from django.conf import settings
import os

# Đường dẫn đến folder chroma_db (nằm ở thư mục gốc project)
CHROMA_DB_PATH = os.path.join(settings.BASE_DIR, 'chroma_db')

class RAGService:
    _instance = None

    @classmethod
    def get_instance(cls):
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    def __init__(self):
        print(f"Loading ChromaDB from {CHROMA_DB_PATH}...")
        self.client = chromadb.PersistentClient(path=CHROMA_DB_PATH)
        # Lưu ý: Bạn cần dùng đúng tên collection đã tạo ở file index_data.py
        self.kb_collection = self.client.get_or_create_collection("gym_knowledge_base")
        self.qa_collection = self.client.get_or_create_collection("gym_qa_data")

    def search(self, query, n_results=3):
        """Tìm kiếm kiến thức liên quan"""
        # 1. Tìm trong QA (Hỏi đáp ngắn) ưu tiên
        qa_results = self.qa_collection.query(
            query_texts=[query],
            n_results=1
        )
        
        # Nếu tìm thấy câu trả lời khớp > 80% (distance < 0.4 tuỳ model)
        # ChromaDB trả về distance, càng nhỏ càng giống.
        if qa_results['distances'][0] and qa_results['distances'][0][0] < 0.4:
             metadata = qa_results['metadatas'][0][0]
             return f"Thông tin nhanh: {metadata.get('answer', '')}"

        # 2. Tìm trong Knowledge Base (Tài liệu dài)
        kb_results = self.kb_collection.query(
            query_texts=[query],
            n_results=n_results
        )
        
        context_list = kb_results['documents'][0]
        return "\n\n".join(context_list)