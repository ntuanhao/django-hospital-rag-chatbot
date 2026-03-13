# api/admin.py
from django.contrib import admin
from .models import (
    UserAccount, Specialty, Service, Appointment, Encounter, 
    Prescription, PrescriptionItem, RecurringSchedule,
    PatientProfile, DoctorProfile, ReceptionistProfile,Medicine
)

@admin.register(UserAccount)
class UserAccountAdmin(admin.ModelAdmin):
    list_display = ('username', 'get_full_name', 'role', 'is_active')
    list_filter = ('role', 'is_active', 'is_superuser')
    search_fields = ('username', 'first_name', 'last_name', 'email')
    ordering = ('username',)
    
    # Loại bỏ các trường chỉ đọc để có thể chỉnh sửa trực tiếp
    # readonly_fields = ('last_login', 'date_joined')
    
    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        ('Thông tin cá nhân', {'fields': ('first_name', 'last_name', 'email', 'phone_number', 'date_of_birth', 'address', 'gender','avatar', )}),
        ('Quyền hạn và Vai trò', {'fields': ('is_active', 'is_superuser', 'role')}),
        ('Ngày quan trọng', {'fields': ('date_joined',)}),
    )

    def get_full_name(self, obj):
        return obj.get_full_name()
    get_full_name.short_description = 'Họ và Tên'

    def save_model(self, request, obj, form, change):
        # Tự động băm mật khẩu khi tạo mới hoặc thay đổi
        if 'password' in form.changed_data or not change:
            obj.set_password(form.cleaned_data['password'])
        super().save_model(request, obj, form, change)



# Đăng ký các model còn lại như bình thường
admin.site.register(Specialty)
admin.site.register(Service)
admin.site.register(RecurringSchedule)
admin.site.register(Appointment)
admin.site.register(Encounter)
admin.site.register(Prescription)
admin.site.register(PrescriptionItem)
admin.site.register(PatientProfile)
admin.site.register(DoctorProfile)
admin.site.register(ReceptionistProfile)
admin.site.register(Medicine)