# hospital_backend/urls.py

from django.contrib import admin
from django.urls import path, include

# <<< BỔ SUNG MỚI >>>
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/", include("api.urls")),
    path("api/chatbot/", include("chatbot.urls")), # <--- Thêm dòng này
]

# <<< BỔ SUNG MỚI >>>: Chỉ phục vụ file media khi ở chế độ DEBUG
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)