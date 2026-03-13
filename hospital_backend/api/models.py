
# api/models.py
from django.db import models
from django.utils import timezone
# Import các hàm để băm và kiểm tra mật khẩu
from django.contrib.auth.hashers import make_password, check_password
from django.core.validators import RegexValidator, MinLengthValidator
from .validators import validate_no_future_date
from django.contrib.auth.models import BaseUserManager

from django.conf import settings

class UserAccountManager(BaseUserManager):
    use_in_migrations = True

    def get_by_natural_key(self, username):
        return self.get(username=username)

    def create_user(self, username, email=None, password=None, **extra_fields):
        if not username:
            raise ValueError("Tên đăng nhập là bắt buộc")
        email = self.normalize_email(email)
        user = self.model(username=username, email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, username, email=None, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("role", UserAccount.Role.ADMIN)
        if not password:
            raise ValueError("Superuser phải có mật khẩu")
        return self.create_user(username, email, password, **extra_fields)

class UserAccount(models.Model):
    class Role(models.TextChoices):
        ADMIN = "ADMIN", "Quản trị viên"
        DOCTOR = "DOCTOR", "Bác sĩ"
        RECEPTIONIST = "RECEPTIONIST", "Lễ tân"
        PATIENT = "PATIENT", "Bệnh nhân"


    # Các trường cơ bản
    # user = models.OneToOneField(
    # settings.AUTH_USER_MODEL,
    # on_delete=models.CASCADE,
    # related_name='useraccount',
    # null=True, blank=True)

    username = models.CharField(max_length=150, unique=True, verbose_name="Tên đăng nhập")
    password = models.CharField(max_length=128, verbose_name="Mật khẩu (đã băm)")
    email = models.EmailField(unique=True, null=True, blank=True)
    first_name = models.CharField(max_length=150, blank=False, verbose_name="Tên")
    last_name = models.CharField(max_length=150, blank=False, verbose_name="Họ")
    
    # Các trường trạng thái
    is_active = models.BooleanField(default=True, verbose_name="Đang hoạt động")
    is_superuser = models.BooleanField(default=False, verbose_name="Là Quản trị viên tối cao")
    
    # Các trường vai trò và thông tin cá nhân
    role = models.CharField(max_length=50, choices=Role.choices, verbose_name="Vai trò trên App")
    phone_number_validator = RegexValidator(
        regex=r'^\d{10,11}$', # Regex này có nghĩa là: chuỗi chỉ chứa số (\d) và có độ dài từ 10 đến 11 ký tự.
        message="Số điện thoại phải có định dạng đúng (10-11 chữ số)."
    )
    phone_number = models.CharField(
        max_length=11, # Độ dài tối đa là 11
        validators=[
            phone_number_validator,
            # MinLengthValidator(10) # Không cần MinLength nữa vì Regex đã bao gồm nó
        ],
        unique=True, 
        null=True, 
        blank=True, 
        verbose_name="Số điện thoại"
    )
    avatar = models.ImageField(upload_to='avatars/', null=True, blank=True, verbose_name="Ảnh đại diện")
    date_of_birth = models.DateField(
        null=True, 
        blank=True, 
        verbose_name="Ngày sinh",
        # Áp dụng validator tùy chỉnh
        validators=[validate_no_future_date]
    )
    address = models.CharField(max_length=255, blank=False, null=True, verbose_name="Địa chỉ")
    
    class Gender(models.TextChoices):
        MALE = "MALE", "Nam"
        FEMALE = "FEMALE", "Nữ"
        OTHER = "OTHER", "Khác"
    gender = models.CharField(max_length=10, choices=Gender.choices, blank=True, null=True, verbose_name="Giới tính")

    date_joined = models.DateTimeField(default=timezone.now, verbose_name="Ngày tham gia")

    # -------------------------------------------------------------------------
    # <<< PHẦN BỔ SUNG ĐỂ TƯƠNG THÍCH VỚI HỆ THỐNG AUTH CỦA DJANGO >>>
    # -------------------------------------------------------------------------
    
    # Các thuộc tính này rất quan trọng để Django nhận diện các trường chính
    # cho các chức năng xác thực, đặc biệt là khi tạo token.
    objects = UserAccountManager()

    USERNAME_FIELD = 'username'
    EMAIL_FIELD = 'email'
    REQUIRED_FIELDS = ['email', 'first_name', 'last_name']
    
    # Hai thuộc tính này là bắt buộc để tích hợp với Django Admin
    is_staff = models.BooleanField(default=False)
    is_anonymous = False # User đã đăng nhập thì không phải anonymous
    is_authenticated = True # User đã đăng nhập thì luôn authenticated

    # Phương thức này giúp Django biết tên của trường email là gì.
    # Đây chính là thứ mà lỗi `get_email_field_name` đang tìm kiếm.
    def get_email_field_name(self):
        return self.EMAIL_FIELD
    
    # -------------------------------------------------------------------------

    # Các phương thức để quản lý mật khẩu
    def set_password(self, raw_password):
        self.password = make_password(raw_password)

    def check_password(self, raw_password):
        return check_password(raw_password, self.password)

    def get_full_name(self):
        return f"{self.last_name} {self.first_name}".strip()
    
    def get_username(self):
       
        return self.username

    def __str__(self):
        return self.username
    

    def has_perm(self, perm, obj=None):
        # Cho phép superuser/admin có tất cả quyền trong trang Admin
        return self.is_superuser or (self.is_staff and self.role == self.Role.ADMIN)

    def has_module_perms(self, app_label):
        # Cho phép superuser/admin truy cập vào các module trong trang Admin
        return self.is_superuser or (self.is_staff and self.role == self.Role.ADMIN)


    class Meta:
        verbose_name = "1. Tài khoản Người dùng (Tùy chỉnh)"
        verbose_name_plural = "1. Các Tài khoản Người dùng (Tùy chỉnh)"


class PatientProfile(models.Model):
    user = models.OneToOneField(
        UserAccount, 
        on_delete=models.CASCADE, 
        primary_key=True, 
        related_name='patient_profile',
        # Chỉ cho phép chọn User có vai trò là Bệnh nhân
        limit_choices_to={'role': UserAccount.Role.PATIENT}
    )
    medical_history = models.TextField(blank=True, null=True, verbose_name="Tiền sử bệnh án")
    allergies = models.TextField(blank=True, null=True, verbose_name="Dị ứng")
    class Meta: 
        verbose_name = "2. Hồ sơ Y tế Bệnh nhân"
        verbose_name_plural = "2. Các hồ sơ Y tế Bệnh nhân"

class DoctorProfile(models.Model):
    user = models.OneToOneField(
        UserAccount, 
        on_delete=models.CASCADE, 
        primary_key=True, 
        related_name='doctor_profile',
        # Chỉ cho phép chọn User có vai trò là Bác sĩ
        limit_choices_to={'role': UserAccount.Role.DOCTOR}
    )
    specialty = models.ForeignKey('Specialty', on_delete=models.SET_NULL, null=True, verbose_name="Chuyên khoa")
    license_number = models.CharField(max_length=50, verbose_name="Số giấy phép hành nghề")
    bio = models.TextField(blank=True, null=True, verbose_name="Tiểu sử/Giới thiệu")
    class Meta: 
        verbose_name = "3. Hồ sơ Chuyên môn Bác sĩ"
        verbose_name_plural = "3. Các hồ sơ Chuyên môn Bác sĩ"

class ReceptionistProfile(models.Model):
    user = models.OneToOneField(
        UserAccount, 
        on_delete=models.CASCADE, 
        primary_key=True, 
        related_name='receptionist_profile',
        # Chỉ cho phép chọn User có vai trò là Lễ tân
        limit_choices_to={'role': UserAccount.Role.RECEPTIONIST}
    )
    employee_id = models.CharField(max_length=20, unique=True, verbose_name="Mã nhân viên")
    start_date = models.DateField(default=timezone.now, verbose_name="Ngày bắt đầu làm việc")
    class Meta: 
        verbose_name = "4. Hồ sơ Lễ tân"
        verbose_name_plural = "4. Các hồ sơ Lễ tân"

class Specialty(models.Model):
    name = models.CharField(max_length=100, unique=True, verbose_name="Tên chuyên khoa")
    class Meta: verbose_name = "5. Danh mục Chuyên khoa"; verbose_name_plural = "5. Các Danh mục Chuyên khoa"

class Service(models.Model):
    name = models.CharField(max_length=200, verbose_name="Tên dịch vụ"); 
    price = models.DecimalField(max_digits=10, decimal_places=0, verbose_name="Giá dịch vụ")
    
    specialties = models.ManyToManyField(
        Specialty,
        related_name='services', # Giúp truy vấn ngược từ Specialty -> Service
        blank=True,
        verbose_name="Thuộc các Chuyên khoa")
    
    class Meta: verbose_name = "6. Danh mục Dịch vụ y tế"; verbose_name_plural = "6. Các Danh mục Dịch vụ y tế"

class RecurringSchedule(models.Model):
    # Enum để chọn ngày trong tuần một cách trực quan
    class Weekday(models.IntegerChoices):
        MONDAY = 0, "Thứ Hai"
        TUESDAY = 1, "Thứ Ba"
        WEDNESDAY = 2, "Thứ Tư"
        THURSDAY = 3, "Thứ Năm"
        FRIDAY = 4, "Thứ Sáu"
        SATURDAY = 5, "Thứ Bảy"
        SUNDAY = 6, "Chủ Nhật"

    doctor = models.ForeignKey(
        UserAccount, 
        on_delete=models.CASCADE,
        limit_choices_to={'role': UserAccount.Role.DOCTOR},
        verbose_name="Bác sĩ"
    )
    day_of_week = models.IntegerField(choices=Weekday.choices, verbose_name="Ngày trong tuần")
    start_time = models.TimeField(verbose_name="Giờ bắt đầu")
    end_time = models.TimeField(verbose_name="Giờ kết thúc")

    class Meta:
        verbose_name = "7. Lịch làm việc Cố định bác sĩ"
        verbose_name_plural = "7. Các Lịch làm việc Cố định của bác sĩ"
        # Đảm bảo một bác sĩ không thể có 2 lịch trùng giờ vào cùng một thứ trong tuần
        unique_together = ('doctor', 'day_of_week', 'start_time')
        ordering = ['doctor', 'day_of_week', 'start_time']

    def __str__(self):
        return f"Lịch làm việc của BS. {self.doctor.username} - {self.get_day_of_week_display()} ({self.start_time}-{self.end_time})"

class Appointment(models.Model):
    class Status(models.TextChoices): PATIENT_REQUESTED = "PATIENT_REQUESTED", "Chờ Lễ tân xác nhận"; RECEPTIONIST_PROPOSED = "RECEPTIONIST_PROPOSED", "Chờ Bệnh nhân xác nhận"; CONFIRMED = "CONFIRMED", "Đã xác nhận"; CHECKED_IN = "CHECKED_IN", "Đã check-in"; COMPLETED = "COMPLETED", "Đã hoàn thành khám"; CANCELLED = "CANCELLED", "Đã hủy"; REJECTED = "REJECTED", "Đã từ chối"
    patient = models.ForeignKey(UserAccount, related_name='patient_appointments', on_delete=models.CASCADE)
    doctor = models.ForeignKey(UserAccount, related_name='doctor_appointments', on_delete=models.CASCADE)
    appointment_time = models.DateTimeField(verbose_name="Thời gian hẹn"); reason = models.TextField(verbose_name="Lý do khám")
    status = models.CharField(max_length=30, choices=Status.choices, default=Status.PATIENT_REQUESTED)
    created_by = models.ForeignKey(UserAccount, related_name='created_appointments', on_delete=models.SET_NULL, null=True, verbose_name="Người khởi tạo")
    receptionist_confirmed_by = models.ForeignKey(UserAccount, related_name='confirmed_appointments', on_delete=models.SET_NULL, null=True, blank=True)
    patient_confirmed_at = models.DateTimeField(null=True, blank=True, verbose_name="Thời điểm Bệnh nhân xác nhận")
    reception_notes = models.TextField(blank=True, null=True, verbose_name="Ghi chú của Lễ tân")
    created_at = models.DateTimeField(auto_now_add=True); updated_at = models.DateTimeField(auto_now=True)

    services = models.ManyToManyField(
        Service,
        blank=True, # Cho phép một lịch hẹn không đăng ký dịch vụ nào
        verbose_name="Các dịch vụ đăng ký"
    )
    
    class Meta: verbose_name = "8. Lịch hẹn"; verbose_name_plural = "8. Các Lịch hẹn"; ordering = ['-appointment_time']

class Encounter(models.Model):
    appointment = models.OneToOneField(Appointment, on_delete=models.CASCADE, verbose_name="Thuộc cuộc hẹn"); 
    symptoms = models.TextField(verbose_name="Triệu chứng"); 
    diagnosis = models.TextField(verbose_name="Chẩn đoán")

    services_performed = models.ManyToManyField(
        Service,
        blank=True, # Cho phép một lần khám không có dịch vụ nào
        verbose_name="Các dịch vụ đã thực hiện"
    )
    
    class Meta: verbose_name = "9. Bệnh án (Lần khám)"; verbose_name_plural = "9. Các Bệnh án (Lần khám)"

class Prescription(models.Model):
    encounter = models.ForeignKey(Encounter, related_name='prescriptions', on_delete=models.CASCADE); notes = models.TextField(blank=True, null=True, verbose_name="Dặn dò thêm")
    class Meta: verbose_name = "10. Đơn thuốc"; verbose_name_plural = "10. Các Đơn thuốc"

class Medicine(models.Model):
    name = models.CharField(max_length=100, unique=True, verbose_name="Tên thuốc")
    description = models.TextField(blank=True, null=True, verbose_name="Mô tả")
    unit = models.CharField(max_length=20, default='Viên', verbose_name="Đơn vị tính")
    stock_quantity = models.PositiveIntegerField(default=0, verbose_name="Số lượng trong kho")

    class Meta:
        verbose_name = "Danh mục Thuốc"
        verbose_name_plural = "Danh mục Thuốc"

    def __str__(self):
        return self.name

class PrescriptionItem(models.Model):
    prescription = models.ForeignKey(Prescription, related_name='items', on_delete=models.CASCADE)
    
    # Thay thế medicine_name bằng ForeignKey đến model Medicine
    medicine = models.ForeignKey(
        Medicine, 
        on_delete=models.CASCADE, # Hoặc models.PROTECT để không cho xóa thuốc đã được kê
        verbose_name="Thuốc",
    )
    
    dosage = models.CharField(max_length=100, verbose_name="Liều lượng/Cách dùng")
    quantity = models.PositiveIntegerField(default=1, verbose_name="Số lượng")

    class Meta:
        verbose_name = "11. Chi tiết Đơn thuốc"
        verbose_name_plural = "11. Các chi tiết Đơn thuốc"


class StockVoucher(models.Model):
    class VoucherType(models.TextChoices):
        STOCK_IN = 'STOCK_IN', 'Phiếu Nhập kho'
        STOCK_OUT = 'STOCK_OUT', 'Phiếu Xuất kho'
    
    voucher_type = models.CharField(max_length=20, choices=VoucherType.choices)
    reason = models.CharField(max_length=255, verbose_name="Lý do/Mô tả")
    created_by = models.ForeignKey(UserAccount, on_delete=models.SET_NULL, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "Phiếu Kho"
        verbose_name_plural = "Các Phiếu Kho"
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.get_voucher_type_display()} - {self.created_at.strftime('%d/%m/%Y')}"
    
    

class StockTransaction(models.Model):
    class TransactionType(models.TextChoices):
        VOUCHER_IN = 'VOUCHER_IN', 'Nhập theo Phiếu'
        VOUCHER_OUT = 'VOUCHER_OUT', 'Xuất theo Phiếu'
        PRESCRIPTION = 'PRESCRIPTION', 'Kê đơn'
        MANUAL_ADJUST = 'MANUAL_ADJUST', 'Điều chỉnh thủ công' # Cho các hành động nhanh


    medicine = models.ForeignKey(Medicine, on_delete=models.CASCADE, related_name='stock_transactions')
    transaction_type = models.CharField(max_length=20, choices=TransactionType.choices)
    quantity = models.IntegerField() # Có thể là số dương (nhập) hoặc âm (xuất)
    notes = models.CharField(max_length=255, blank=True, null=True, verbose_name="Ghi chú/Lý do")
    created_by = models.ForeignKey(
        UserAccount, 
        on_delete=models.SET_NULL, 
        null=True,
        limit_choices_to={'role__in': [UserAccount.Role.ADMIN, UserAccount.Role.DOCTOR]}
    )
    created_at = models.DateTimeField(auto_now_add=True)

    voucher = models.ForeignKey(StockVoucher, on_delete=models.CASCADE, null=True, blank=True, related_name='transactions')

    class Meta:
        verbose_name = "Lịch sử Giao dịch Kho"
        verbose_name_plural = "Lịch sử Giao dịch Kho"
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.get_transaction_type_display()} - {self.medicine.name} - SL: {self.quantity}"
