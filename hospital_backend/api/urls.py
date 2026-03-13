

# api/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

from rest_framework_simplejwt.views import TokenRefreshView

# DefaultRouter sẽ tự động tạo các URL cho các ViewSet.
# - GET, POST, PUT, DELETE cho các endpoint chính (ví dụ: /users/, /users/{id}/)
# - GET, POST cho các action tùy chỉnh (ví dụ: /users/me/, /users/set-password/)
router = DefaultRouter()

# Đăng ký các ViewSet với router. Router sẽ tự xử lý các URL cho chúng.
# Lưu ý: UserViewSet giờ đã bao gồm cả chức năng của ProfileViewSet cũ.
router.register('users', views.UserViewSet, basename='user')
router.register('specialties', views.SpecialtyViewSet, basename='specialty')
router.register('services', views.ServiceViewSet, basename='service')
router.register('recurring-schedules', views.RecurringScheduleViewSet, basename='recurring-schedules')
router.register('appointments', views.AppointmentViewSet, basename='appointment')
router.register('encounters', views.EncounterViewSet, basename='encounter')
router.register('medicines', views.MedicineViewSet, basename='medicine')
router.register('stock-transactions', views.StockTransactionViewSet, basename='stock-transaction')

router.register('stock-vouchers', views.StockVoucherViewSet, basename='stock-voucher')


# urlpatterns là danh sách cuối cùng chứa tất cả các URL của API.
urlpatterns = [
    # 1. Các URL được router tự động tạo ra cho các ViewSet ở trên.
    #    Bao gồm cả các action mới như /users/me/ và /users/set-password/
    path('', include(router.urls)),
    
    # 2. Các URL cho các View riêng lẻ (Authentication, Registration, Password Reset)
    #    Chúng ta định nghĩa chúng thủ công ở đây.
    
    # Đăng ký và Đăng nhập
    path('auth/register/', views.RegisterView.as_view(), name='register'),
    path('auth/login/', views.UserAccountLoginView.as_view(), name='login'),
    
    path('auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('search/', views.GlobalSearchView.as_view(), name='global-search'),
    # path('admin/reports/appointments-over-time/', views.AdminReportView.as_view(), name='admin-report-appointments'),
    path('admin/reports/<str:report_type>/', views.AdminReportView.as_view(), name='admin-reports'),
    
]