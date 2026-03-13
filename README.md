# 🏥 Hospital Management System & AI RAG Chatbot (Django REST Framework)

![Python](https://img.shields.io/badge/Python-3.9%2B-blue?logo=python&logoColor=white)
![Django](https://img.shields.io/badge/Django-5.x-092E20?logo=django&logoColor=white)
![DRF](https://img.shields.io/badge/DRF-Red?logo=django&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?logo=postgresql&logoColor=white)
![LangChain](https://img.shields.io/badge/LangChain-Green?logo=chainlink&logoColor=white)
![Gemini](https://img.shields.io/badge/Google_Gemini-8E75B2?logo=google&logoColor=white)
![ChromaDB](https://img.shields.io/badge/ChromaDB-Vector_Store-orange)

> **Graduation Thesis 2026 - Ho Chi Minh City University of Natural Resources and Environment (HCMUNRE)**

Comprehensive Backend API for a Hospital Management System integrated with an intelligent Medical Virtual Assistant. The chatbot leverages **RAG (Retrieval-Augmented Generation)** architecture to provide accurate medical information, service pricing, and booking guidance based on a customized Vietnamese medical knowledge base.

---

## 👨‍💻 Author Information

* **Author:** Nguyen Tuan Hao
* **University:** Ho Chi Minh City University of Natural Resources and Environment (HCMUNRE)
* **Email:** [tuanhao050403@gmail.com](mailto:tuanhao050403@gmail.com)
* **LinkedIn:** [tuấn-hào-a34b9b218](https://www.linkedin.com/in/tuấn-hào-a34b9b218)
* **Repository:** [ntuanhao/django-hospital-rag-chatbot](https://github.com/ntuanhao/django-hospital-rag-chatbot.git)

---

## 🌟 Key Features

### 1. Core Hospital Management (RESTful API)
* **Role-Based Access Control (RBAC):** Custom User Model with strict permissions for 4 roles: `ADMIN`, `DOCTOR`, `RECEPTIONIST`, and `PATIENT`.
* **JWT Authentication:** Secure login and token lifecycle management using `SimpleJWT`.
* **Appointment Scheduling:** Intelligent booking system with overlap prevention, status tracking (Requested, Confirmed, Checked-in, Completed, Cancelled), and available slot generation.
* **Medical Encounters & Prescriptions:** Doctors can create patient encounters, record symptoms/diagnoses, and prescribe medicines.
* **Inventory Management:** Robust medicine stock tracking. Automatic stock deduction upon prescription creation, and manual stock adjustment with `StockVoucher` and `StockTransaction` history.
* **Analytics & Reporting:** Admin endpoints for appointment status distributions and inventory flow (built with `pandas` for data aggregation).

### 2. AI Medical Assistant (RAG Architecture)
* **Context-Aware Chatbot:** Identifies the logged-in patient and injects their medical history and allergies into the LLM prompt for highly personalized advice.
* **Vietnamese Optimized RAG:** Uses `bkai-foundation-models/vietnamese-bi-encoder` to generate accurate vector embeddings for Vietnamese medical documents.
* **Vector Database:** Integrates `ChromaDB` to store and retrieve chunks from a vast medical knowledge base (Internal Medicine, Cardiology, Dermatology, etc.).
* **Tool Calling capability:** The Agent automatically triggers database queries (e.g., fetching hospital service prices) when the user asks about costs.
* **Actionable UI Response:** The LLM is engineered to return pure JSON containing `answer_text` and `suggested_actions` (e.g., buttons to book an appointment or view a service), making Frontend integration seamless.

---

## 🛠️ Technology Stack
* **Backend Framework:** Django, Django REST Framework (DRF)
* **Database:** PostgreSQL (Relational Data), ChromaDB (Vector Data)
* **Authentication:** JSON Web Tokens (JWT)
* **AI & LLM:** LangChain, Google Generative AI (Gemini 1.5 Flash)
* **NLP / Embeddings:** SentenceTransformers (`bkai-foundation-models/vietnamese-bi-encoder`)
* **Data Processing:** Pandas, Django ORM (aggregation & annotations)

---

## 🧠 RAG System Architecture

The Chatbot is not just a wrapper around an API; it uses a full RAG pipeline to ensure medical accuracy and avoid hallucinations:

1. **Ingestion Phase (`index_data.py`):** 
   - Reads `knowledge_base.json` and `q&a_data.json`.
   - Uses the local Vietnamese Bi-encoder model to convert text into dense vectors.
   - Stores vectors and metadata persistently in `ChromaDB`.

2. **Retrieval Phase:** 
   - User sends a message.
   - The query is vectorized and performs a semantic search in ChromaDB (distance < 0.4 prioritizing QA data, fallback to detailed docs).

3. **Generation Phase (`agent.py`):** 
   - LangChain constructs a prompt combining: *User Query + Retrieved Medical Context + Patient's Medical History + Real-time Service Pricing (Tool).*
   - `Gemini 1.5 Flash` synthesizes the final response and formats it strictly as JSON.

---

## ⚙️ Installation & Setup

### Prerequisites
* Python 3.9+
* PostgreSQL

### 1. Clone the repository
```bash
git clone https://github.com/ntuanhao/django-hospital-rag-chatbot.git
cd django-hospital-rag-chatbot/hospital_backend
```

### 2. Setup Virtual Environment
```bash
python -m venv venv
source venv/Scripts/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```
*(Note: Ensure torch, sentence-transformers, langchain-google-genai, chromadb, and pandas are in your requirements.txt)*

### 3. Environment Variables
Create a `.env` file in the `hospital_backend/` directory:
```env
SECRET_KEY=your_django_secret_key
DEBUG=True

# Database
DB_NAME=datn
DB_USER=postgres
DB_PASSWORD=your_db_password
DB_HOST=127.0.0.1
DB_PORT=5432

# Google Gemini API
GOOGLE_API_KEY=your_gemini_api_key
```

### 4. Database Migration & Superuser
```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
```

### 5. Initialize Vector Database (RAG)
Run the script to download the Vietnamese embedding model and index the medical knowledge into ChromaDB. (First run will take some time to download the model).
```bash
python api/index_data.py
```

### 6. Run the Server
```bash
python manage.py runserver
```
You can test the chatbot UI instantly by opening `chatbot_test.html` in your browser.

---

## 📡 Core API Endpoints

| Endpoint | Method | Description | Role |
| :--- | :--- | :--- | :--- |
| `/api/auth/login/` | POST | Obtain JWT Access & Refresh Tokens | All |
| `/api/users/` | GET/POST | Manage Users & Profiles | Admin/All |
| `/api/appointments/` | GET/POST | Create & view appointments | Patient/Recep |
| `/api/appointments/<id>/check_in/` | POST | Update status to CHECKED_IN | Recep/Admin |
| `/api/encounters/` | POST | Create medical record & prescription | Doctor |
| `/api/stock-vouchers/` | POST | Import/Export medicines (Inventory) | Admin |
| `/api/admin/reports/<type>/` | GET | Generate charts (Appointments, Stock) | Admin |
| `/api/chatbot/ask/` | POST | Chat with Medical AI Assistant | Patient |

---

## 💡 System Demo (JSON Output Example)

**Request:** `POST /api/chatbot/ask/`
```json
{
    "message": "Giá khám nội tổng quát bao nhiêu? Tôi muốn đặt lịch."
}
```

**Response (Generated by Gemini Agent):**
```json
{
    "answer_text": "Chào Hào, dựa trên thông tin bệnh viện, giá Khám Nội Tổng Quát hiện tại là 150,000 VNĐ. Khám nội tổng quát giúp đánh giá sức khỏe toàn diện và phát hiện sớm các bệnh lý thầm lặng như tăng huyết áp hay đái tháo đường. Bạn có muốn tôi hướng dẫn đặt lịch khám ngay bây giờ không? 🏥",
    "suggested_actions":[
        {
            "type": "VIEW_SERVICE",
            "payload": { "keyword": "Khám Nội Tổng Quát" }
        },
        {
            "type": "BOOK_APPOINTMENT",
            "label": "Đặt lịch ngay"
        }
    ]
}
```

<div align="center">
  <i>If you find this project interesting, please consider giving it a ⭐!</i><br>
  <i>Built with passion by <b>Nguyen Tuan Hao</b></i>
</div>
