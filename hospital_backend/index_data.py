import json
import chromadb
from sentence_transformers import SentenceTransformer
import sys
import os

# --- 1. CẤU HÌNH BAN ĐẦU ---

# Khởi tạo ChromaDB client.
client = chromadb.PersistentClient(path="chroma_db")

print("⏳ Đang tải model embedding (bkai-foundation-models/vietnamese-bi-encoder)...")
# Load model Tiếng Việt vào bộ nhớ
embedding_model = SentenceTransformer('bkai-foundation-models/vietnamese-bi-encoder')
print("✅ Model đã sẵn sàng.")

KNOWLEDGE_BASE_COLLECTION = "gym_knowledge_base"
QA_DATA_COLLECTION = "gym_qa_data"

# --- 2. HÀM XỬ LÝ VÀ NẠP DỮ LIỆU ---

def get_or_create_collections():
    """Lấy hoặc tạo các collection cần thiết."""
    # Lưu ý: Không truyền embedding_function vào đây để ta tự xử lý thủ công
    kb_collection = client.get_or_create_collection(name=KNOWLEDGE_BASE_COLLECTION)
    qa_collection = client.get_or_create_collection(name=QA_DATA_COLLECTION)
    print(f"Collection '{KNOWLEDGE_BASE_COLLECTION}' và '{QA_DATA_COLLECTION}' đã sẵn sàng.")
    return kb_collection, qa_collection

def index_knowledge_base(collection):
    """Đọc file knowledge_base.json và nạp vào ChromaDB."""
    print("\n--- Bắt đầu nạp dữ liệu từ knowledge_base.json ---")
    file_path = 'knowledge_base.json'
    
    if not os.path.exists(file_path):
        print(f"❌ Lỗi: Không tìm thấy file {file_path}")
        return

    try:
        with open(file_path, 'r', encoding='utf-8-sig') as f:
            data = json.load(f)
            if isinstance(data, dict):
                for key in ['data', 'content', 'chunks', 'documents']:
                    if key in data and isinstance(data[key], list):
                        data = data[key]
                        break
    except (json.JSONDecodeError) as e:
        print(f"❌ Lỗi cấu trúc JSON: {e}")
        return

    if not isinstance(data, list):
        print(f"❌ Dữ liệu không phải là danh sách (List).")
        return

    documents = []
    metadatas = []
    ids = []
    
    # Lọc dữ liệu lỗi
    for i, chunk in enumerate(data):
        if isinstance(chunk, dict) and 'content' in chunk:
            documents.append(chunk['content'])
            meta = chunk.get('metadata', {})
            if meta is None: meta = {}
            metadatas.append(meta)
            ids.append(f"kb_{i}")

    if not documents:
        print("❌ Không có dữ liệu hợp lệ để nạp.")
        return

    # Xóa dữ liệu cũ
    try:
        existing = collection.get()
        if existing['ids']:
            collection.delete(ids=existing['ids'])
    except Exception:
        pass
    
    # --- THAY ĐỔI QUAN TRỌNG: CHIA BATCH VÀ TỰ TẠO EMBEDDING ---
    batch_size = 50 # Giảm batch size xuống cho an toàn
    total = len(documents)
    print(f"🔄 Đang xử lý {total} văn bản...")

    for i in range(0, total, batch_size):
        end = min(i + batch_size, total)
        batch_docs = documents[i:end]
        batch_metas = metadatas[i:end]
        batch_ids = ids[i:end]

        # Tự tạo embedding bằng model Tiếng Việt của mình
        print(f"   -> Đang tạo vector cho batch {i}-{end}...")
        batch_embeddings = embedding_model.encode(batch_docs).tolist()

        # Thêm vào DB (truyền sẵn embeddings để ChromaDB không tự tải model khác)
        collection.add(
            embeddings=batch_embeddings,
            documents=batch_docs,
            metadatas=batch_metas,
            ids=batch_ids
        )
        print(f"   ✅ Đã nạp xong batch {i}-{end}")

    print(f"🎉 Hoàn thành nạp Knowledge Base!")

def index_qa_data(collection):
    """Đọc file q&a_data.json và nạp vào ChromaDB."""
    print("\n--- Bắt đầu nạp dữ liệu từ q&a_data.json ---")
    file_path = 'q&a_data.json'

    if not os.path.exists(file_path):
        print(f"❌ Lỗi: Không tìm thấy file {file_path}")
        return

    try:
        with open(file_path, 'r', encoding='utf-8-sig') as f:
            data = json.load(f)
            if isinstance(data, dict) and "qa_pairs" in data:
                data = data["qa_pairs"]
            elif isinstance(data, dict):
                for key in ['data', 'questions', 'items']:
                    if key in data and isinstance(data[key], list):
                        data = data[key]
                        break
    except Exception as e:
        print(f"❌ Lỗi đọc file: {e}")
        return

    documents = []
    metadatas = []
    ids = []

    for i, pair in enumerate(data):
        if isinstance(pair, dict) and 'questions' in pair and 'answer' in pair:
            combined_questions = " ".join(pair['questions'])
            documents.append(combined_questions)
            meta = pair.get('metadata', {})
            if meta is None: meta = {}
            meta['answer'] = pair['answer']
            if 'topic' in pair: meta['topic'] = pair['topic']
            
            metadatas.append(meta)
            ids.append(f"qa_{i}")

    if not documents:
        print("❌ Không có dữ liệu Q&A hợp lệ.")
        return

    try:
        existing = collection.get()
        if existing['ids']:
            collection.delete(ids=existing['ids'])
    except Exception:
        pass

    # --- THAY ĐỔI QUAN TRỌNG: TỰ TẠO EMBEDDING ---
    print(f"🔄 Đang xử lý {len(documents)} cặp câu hỏi...")
    
    # Tạo vector cho toàn bộ (vì data Q&A thường ít hơn KB)
    embeddings = embedding_model.encode(documents).tolist()

    collection.add(
        embeddings=embeddings,
        documents=documents,
        metadatas=metadatas,
        ids=ids
    )
    print(f"🎉 Hoàn thành nạp Q&A Data!")

# --- 3. CHẠY CHƯƠNG TRÌNH ---
if __name__ == "__main__":
    kb_collection, qa_collection = get_or_create_collections()
    index_knowledge_base(kb_collection)
    index_qa_data(qa_collection)