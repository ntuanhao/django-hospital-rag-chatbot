# hospital_backend/settings.py

from pathlib import Path
import os
from datetime import timedelta
from dotenv import load_dotenv

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# <<< CẢI TIẾN BẢO MẬT >>>: Tải các biến môi trường từ file .env
load_dotenv(os.path.join(BASE_DIR, '.env'))

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.environ.get('SECRET_KEY')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = os.environ.get('DEBUG') == 'True'

ALLOWED_HOSTS = ['*','192.168.1.236'] 
# ALLOWED_HOSTS = ['localhost', '127.0.0.1', '192.168.1.236', '192.168.43.228']# Bỏ '*' đi cho an toàn


# Application definition
INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    'api',
    'core',
    'django_filters',
    'chatbot',
    'rest_framework',
    'rest_framework_simplejwt',
    
    # <<< BỔ SUNG MỚI >>>: Thêm corsheaders
    # 'corsheaders',
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    # <<< BỔ SUNG MỚI >>>: Thêm CorsMiddleware, đặt ở vị trí cao
    # "corsheaders.middleware.CorsMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

# <<< BỔ SUNG MỚI >>>: Cấu hình CORS
# CORS_ALLOWED_ORIGINS = [
#     # Thêm địa chỉ của Flutter Web app của bạn vào đây
#     "http://localhost:3000",
#     "http://127.0.0.1:3000",
# ]

# Cho phép mọi nguồn để dễ test HTML file local
CORS_ALLOW_ALL_ORIGINS = True

# Hoặc cho phép tất cả trong môi trường dev (thận trọng khi dùng)
# CORS_ALLOW_ALL_ORIGINS = True


ROOT_URLCONF = "hospital_backend.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "hospital_backend.wsgi.application"

# <<< CẢI TIẾN BẢO MẬT >>>: Đọc thông tin database từ file .env
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DB_NAME'),
        'USER': os.environ.get('DB_USER'),
        'PASSWORD': os.environ.get('DB_PASSWORD'),
        'HOST': os.environ.get('DB_HOST'),
        'PORT': os.environ.get('DB_PORT'),
        # 'OPTIONS': {
        #     'init_command': "SET sql_mode='STRICT_TRANS_TABLES'",
        # },
    }
}

# Lưu ý: Vì bạn xây dựng hệ thống auth riêng nên không cần khai báo AUTH_USER_MODEL.
# Tuy nhiên, nếu sau này cần tích hợp sâu hơn, bạn sẽ cần nó:
# AUTH_USER_MODEL = 'api.UserAccount'

AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

# Internationalization
LANGUAGE_CODE = 'vi'
TIME_ZONE = 'Asia/Ho_Chi_Minh'
USE_I1N = True
USE_TZ = True

# Static files (CSS, JavaScript, Images)
STATIC_URL = "static/"
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

# <<< BỔ SUNG MỚI >>>: Cấu hình cho file Media (ví dụ: avatar)
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# Default primary key field type
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# <<< CẢI TIẾN >>>: Cấu hình đầy đủ hơn cho DRF
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        # Yêu cầu phải xác thực cho tất cả các API, trừ các API được đánh dấu AllowAny
        'rest_framework.permissions.IsAuthenticated',
    ),
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend'
    ]
}
AUTH_USER_MODEL = 'api.UserAccount'
# SIMPLE_JWT = {
#     'ACCESS_TOKEN_LIFETIME': timedelta(minutes=60),
#     'REFRESH_TOKEN_LIFETIME': timedelta(days=1),
# }

SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=60), # Token truy cập có hiệu lực trong 60 phút
    "REFRESH_TOKEN_LIFETIME": timedelta(days=365),    # Token làm mới có hiệu lực trong 1 ngày
    "ROTATE_REFRESH_TOKENS": False,
    "BLACKLIST_AFTER_ROTATION": False,
    "UPDATE_LAST_LOGIN": True, # Cập nhật trường last_login khi đăng nhập

    "ALGORITHM": "HS256", # Thuật toán ký, HS256 là mặc định và an toàn
    "SIGNING_KEY": SECRET_KEY, # Dùng SECRET_KEY của Django để ký token
    "VERIFYING_KEY": None,
    "AUDIENCE": None,
    "ISSUER": None,
    "JWK_URL": None,
    "LEEWAY": 0,

    "AUTH_HEADER_TYPES": ("Bearer",), # Chỉ chấp nhận header "Bearer <token>"
    "AUTH_HEADER_NAME": "HTTP_AUTHORIZATION",
    "USER_ID_FIELD": "id",
    "USER_ID_CLAIM": "user_id",
    "USER_AUTHENTICATION_RULE": "rest_framework_simplejwt.authentication.default_user_authentication_rule",

    "AUTH_TOKEN_CLASSES": ("rest_framework_simplejwt.tokens.AccessToken",),
    "TOKEN_TYPE_CLAIM": "token_type",
    "TOKEN_USER_CLASS": "rest_framework_simplejwt.models.TokenUser",

    "JTI_CLAIM": "jti",

    "SLIDING_TOKEN_REFRESH_EXP_CLAIM": "refresh_exp",
    "SLIDING_TOKEN_LIFETIME": timedelta(minutes=5),
    "SLIDING_TOKEN_REFRESH_LIFETIME": timedelta(days=1),
}
PASSWORD_RESET_TIMEOUT = 259200


# # <<< BỔ SUNG MỚI >>>: Cấu hình gửi Email từ file .env
# EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
# EMAIL_HOST = os.environ.get('EMAIL_HOST')
# EMAIL_PORT = int(os.environ.get('EMAIL_PORT', 587))
# EMAIL_USE_TLS = os.environ.get('EMAIL_USE_TLS') == 'True'
# EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER')
# EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD')
# DEFAULT_FROM_EMAIL = os.environ.get('DEFAULT_FROM_EMAIL', EMAIL_HOST_USER)

# Dùng dòng này để test gửi email trên console mà không cần SMTP thật
# EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'