# api/serializers.py
from rest_framework import serializers
from .models import *
from django.utils import timezone
from django.db import transaction


# đổi mật khẩu
class ChangePasswordSerializer(serializers.Serializer):
    """
    Serializer cho chức năng "Đổi mật khẩu" khi người dùng đã đăng nhập.
    Yêu cầu mật khẩu cũ và mật khẩu mới (nhập 2 lần để xác nhận).
    """
    old_password = serializers.CharField(required=True, write_only=True)
    new_password1 = serializers.CharField(required=True, write_only=True)
    new_password2 = serializers.CharField(required=True, write_only=True)

    def validate(self, data):
        # Kiểm tra hai mật khẩu mới có khớp nhau không
        if data['new_password1'] != data['new_password2']:
            raise serializers.ValidationError({"new_password2": "Mật khẩu mới không khớp."})
        
        # Lấy thông tin user đang thực hiện request
        user = self.context['request'].user
        
        # Kiểm tra mật khẩu cũ có đúng không
        if not user.check_password(data['old_password']):
            raise serializers.ValidationError({"old_password": "Mật khẩu cũ không chính xác."})
        
        return data

    def save(self, **kwargs):
        # Sau khi validate thành công, lưu mật khẩu mới
        user = self.context['request'].user
        user.set_password(self.validated_data['new_password1'])
        user.save()
        return user

class PasswordResetRequestSerializer(serializers.Serializer):
    """
    Serializer cho chức năng "Quên mật khẩu - Bước 1: Yêu cầu reset".
    Chỉ cần người dùng nhập email của họ.
    """
    email = serializers.EmailField(required=True)

class PasswordResetConfirmSerializer(serializers.Serializer):
    """
    Serializer cho chức năng "Quên mật khẩu - Bước 2: Xác nhận mật khẩu mới".
    Yêu cầu người dùng cung cấp token và mật khẩu mới.
    """
    token = serializers.CharField(required=True)
    new_password1 = serializers.CharField(required=True, write_only=True)
    new_password2 = serializers.CharField(required=True, write_only=True)

    def validate(self, data):
        # Kiểm tra hai mật khẩu mới có khớp nhau không
        if data['new_password1'] != data['new_password2']:
            raise serializers.ValidationError({"new_password2": "Mật khẩu mới không khớp."})
        
        # Việc xác thực token sẽ được thực hiện ở tầng View
        return data

# ===================================================================
# 1. SERIALIZERS CHO CÁC DANH MỤC VÀ HỒ SƠ CÁ NHÂN
# ===================================================================

class SpecialtySerializer(serializers.ModelSerializer):
    class Meta:
        model = Specialty
        fields = '__all__'

class ServiceSerializer(serializers.ModelSerializer):
    def validate_price(self, v):
        if v < 0:
            raise serializers.ValidationError("Giá phải >= 0")
        return v

    class Meta:
        model = Service
        fields = '__all__'

class PatientProfileSerializer(serializers.ModelSerializer):
    """ Dùng để xem và cập nhật thông tin hồ sơ bệnh nhân. """
    class Meta:
        model = PatientProfile
        fields = ['user', 'medical_history', 'allergies']
        # <<< CẢI TIẾN >>>: User không thể bị thay đổi, chỉ dùng để tham chiếu.
        read_only_fields = ['user','medical_history']

class DoctorProfileSerializer(serializers.ModelSerializer):
    """ Dùng để xem và cập nhật thông tin hồ sơ bác sĩ. """
    specialty_name = serializers.CharField(source='specialty.name', read_only=True)
    class Meta:
        model = DoctorProfile
        fields = ['user', 'specialty', 'specialty_name', 'license_number', 'bio']
        # <<< CẢI TIẾN >>>: User không đổi, specialty chỉ nhận ID khi ghi.
        # read_only_fields = ['user','specialty','license_number']
        read_only_fields = ['user', 'specialty_name']
        extra_kwargs = {'specialty': {'write_only': True}}

class ReceptionistProfileSerializer(serializers.ModelSerializer):
    """ Dùng để xem và cập nhật thông tin hồ sơ lễ tân. """
    class Meta:
        model = ReceptionistProfile
        fields = ['user', 'employee_id', 'start_date']
        read_only_fields = ['user']

# ===================================================================
# 2. SERIALIZERS CHO NGƯỜI DÙNG (USERACCOUNT)
# ===================================================================

class UserAccountSummarySerializer(serializers.ModelSerializer):
    """
    # <<< CẢI TIẾN MỚI >>>
    # Serializer TÓM TẮT thông tin user. Dùng khi lồng vào các object khác
    # để tránh trả về dữ liệu quá lớn, tăng hiệu suất.
    """
    full_name = serializers.CharField(source='get_full_name', read_only=True)
    
    class Meta:
        model = UserAccount
        fields = ['id', 'username', 'full_name', 'role', 'avatar']

    def get_avatar(self, obj):
        """
        Trả về URL đầy đủ của avatar.
        """
        request = self.context.get('request')
        if request and obj.avatar:
            return request.build_absolute_uri(obj.avatar.url)
        return None

class UserAccountSerializer(serializers.ModelSerializer):
    """ Dùng để hiển thị thông tin CHI TIẾT của một user. """
    # <<< CẢI TIẾN >>>: Tạo một trường 'profile' duy nhất, tự động trả về
    # profile tương ứng với vai trò của user, giúp API gọn gàng hơn.
    profile = serializers.SerializerMethodField()

    class Meta:
        model = UserAccount
        fields = [
            'id', 'username', 'first_name', 'last_name', 'email', 'role',
            'phone_number', 'avatar', 'date_of_birth', 'address', 'gender',
            'profile'  # <<< CẢI TIẾN >>>
        ]

    def get_profile(self, obj):
        """
        Dựa vào vai trò của user (obj.role), trả về dữ liệu profile tương ứng.
        """
        if obj.role == UserAccount.Role.PATIENT and hasattr(obj, 'patient_profile'):
            return PatientProfileSerializer(obj.patient_profile).data
        if obj.role == UserAccount.Role.DOCTOR and hasattr(obj, 'doctor_profile'):
            return DoctorProfileSerializer(obj.doctor_profile).data
        if obj.role == UserAccount.Role.RECEPTIONIST and hasattr(obj, 'receptionist_profile'):
            return ReceptionistProfileSerializer(obj.receptionist_profile).data
        return None

    def get_avatar(self, obj):
        """
        Trả về URL đầy đủ của avatar, đúng như logic ban đầu của bạn.
        """
        request = self.context.get('request')
        if request and obj.avatar:
            return request.build_absolute_uri(obj.avatar.url)
        return None

class UserAccountUpdateSerializer(serializers.ModelSerializer):
    """
    Serializer cho phép người dùng tự cập nhật thông tin CƠ BẢN của họ.
    Không cho phép thay đổi username, role.
    """
    class Meta:
        model = UserAccount
        fields = [
            'first_name', 'last_name', 'email', 'phone_number',
            'avatar', 'date_of_birth', 'address', 'gender'
        ]



class RegisterSerializer(serializers.ModelSerializer):
    """ Dành riêng cho việc Bệnh nhân tự đăng ký tài khoản. """
    class Meta:
        model = UserAccount
        fields = [
            'username', 'password', 'first_name', 'last_name', 'email',
            'phone_number', 'date_of_birth', 'address', 'gender'
        ]
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = UserAccount(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
            phone_number=validated_data.get('phone_number'),
            date_of_birth=validated_data.get('date_of_birth'),
            address=validated_data.get('address'),
            gender=validated_data.get('gender'),
            role=UserAccount.Role.PATIENT,
            is_active=True  # <<< THAY ĐỔI QUAN TRỌNG Ở ĐÂY
        )
        user.set_password(validated_data['password'])
        user.save()
        PatientProfile.objects.create(user=user)
        return user

class AdminCreateUserSerializer(serializers.ModelSerializer):
    """
    Serializer dành cho Admin/Quản lý tạo tài khoản mới
    cho Bác sĩ, Lễ tân hoặc các Admin khác.
    """
    class Meta:
        model = UserAccount
        # Thêm role vào đây để Admin có thể chỉ định vai trò
        fields = [
            'username', 'password', 'first_name', 'last_name', 'email',
            'phone_number', 'role'
        ]
        extra_kwargs = {'password': {'write_only': True}}

    # Ghi đè phương thức create để xử lý việc tạo Profile
    def create(self, validated_data):
        role = validated_data.get('role')
        user = UserAccount(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
            phone_number=validated_data.get('phone_number'),
            role=role
        )
        user.set_password(validated_data['password'])
        user.save()

        # Tự động tạo Profile tương ứng (giống logic chúng ta đã bàn)
        if role == UserAccount.Role.DOCTOR:
            DoctorProfile.objects.create(user=user)
        elif role == UserAccount.Role.RECEPTIONIST:
            ReceptionistProfile.objects.create(user=user)
        elif role == UserAccount.Role.PATIENT:
            PatientProfile.objects.create(user=user)
        return user
# ===================================================================
# 3. SERIALIZERS CHO CÁC NGHIỆP VỤ
# ===================================================================


# class RecurringScheduleSerializer(serializers.ModelSerializer):
#     day_of_week_display = serializers.CharField(source='get_day_of_week_display', read_only=True)
#     doctor_id = serializers.IntegerField(source='doctor.id', read_only=True)

#     class Meta:
#         model = RecurringSchedule
#         fields = [
#             'id',
#             'doctor_id',
#             'day_of_week',
#             'day_of_week_display',
#             'start_time',
#             'end_time',
#         ]
class RecurringScheduleSerializer(serializers.ModelSerializer):
    day_of_week_display = serializers.CharField(source='get_day_of_week_display', read_only=True)
    
    # <<< THAY ĐỔI 1: doctor_id sẽ chỉ được đọc, không dùng để ghi >>>
    doctor_id = serializers.IntegerField(source='doctor.id', read_only=True)
    
    # <<< THAY ĐỔI 2: Thêm trường `doctor` để nhận ID khi tạo/ghi dữ liệu >>>
    # queryset đảm bảo chỉ có thể chọn user là Bác sĩ.
    # write_only=True nghĩa là trường này chỉ dùng để nhận dữ liệu, không hiển thị ra trong API response.
    doctor = serializers.PrimaryKeyRelatedField(
        queryset=UserAccount.objects.filter(role=UserAccount.Role.DOCTOR),
        write_only=True
    )

    class Meta:
        model = RecurringSchedule
        fields = [
            'id',
            'doctor', # <<< THÊM `doctor` vào đây
            'doctor_id',
            'day_of_week',
            'day_of_week_display',
            'start_time',
            'end_time',
        ]


class AppointmentSerializer(serializers.ModelSerializer):
    # <<< CẢI TIẾN >>>: Sử dụng serializer tóm tắt để tăng hiệu suất.
    patient = UserAccountSummarySerializer(read_only=True)
    doctor = UserAccountSummarySerializer(read_only=True)
    created_by = UserAccountSummarySerializer(read_only=True)
    patient_id = serializers.PrimaryKeyRelatedField(
         queryset=UserAccount.objects.filter(role=UserAccount.Role.PATIENT), 
         source='patient', 
         write_only=True,
         required=False # <<< THÊM DÒNG NÀY
     )
    doctor_id = serializers.PrimaryKeyRelatedField(
        queryset=UserAccount.objects.filter(role=UserAccount.Role.DOCTOR), source='doctor', write_only=True
    )
    
    services_details = ServiceSerializer(source='services', many=True, read_only=True)
    class Meta:
        model = Appointment
        fields = [
            'id', 'patient', 'doctor', 'patient_id', 'doctor_id',
            'appointment_time', 'reason', 'status', 'reception_notes',
            'created_by', 'created_at', 'updated_at','services','services_details'
        ]
        # <<< CẢI TIẾN >>>: Thêm receptionist_confirmed_by vào read_only
        read_only_fields = ('status', 'created_by', 'receptionist_confirmed_by', 'patient_confirmed_at')

        extra_kwargs = {
            'services': {'write_only': True, 'required': False}
        }


    def validate_appointment_time(self, dt):
        if dt <= timezone.now():
            raise serializers.ValidationError("Thời gian hẹn phải ở tương lai")
        return dt

    def create(self, validated_data):
        req = self.context.get('request')
        if req and req.user.is_authenticated:
            validated_data['created_by'] = req.user
        return super().create(validated_data)

class AppointmentStatusUpdateSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = Appointment
        fields = ['status'] # Chỉ cho phép thay đổi duy nhất trường status


class AppointmentRejectSerializer(serializers.Serializer):
    """
    Serializer để nhận lý do từ chối từ Lễ tân.
    """
    reason = serializers.CharField(required=True, allow_blank=False)



class PrescriptionItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = PrescriptionItem
        fields = ['id', 'medicine_name', 'dosage', 'quantity']

class PrescriptionSerializer(serializers.ModelSerializer):
    items = PrescriptionItemSerializer(many=True)

    class Meta:
        model = Prescription
        fields = ['id', 'encounter', 'notes', 'items']
        # <<< CẢI TIẾN >>>: `encounter` nên được cung cấp khi tạo, không nên thay đổi.
        extra_kwargs = {'encounter': {'write_only': True}}

    def create(self, validated_data):
        items_data = validated_data.pop('items')
        prescription = Prescription.objects.create(**validated_data)
        for item_data in items_data:
            PrescriptionItem.objects.create(prescription=prescription, **item_data)
        return prescription





# <<< THÊM SERIALIZER MỚI CHO MEDICINE >>>
class MedicineSerializer(serializers.ModelSerializer):
    class Meta:
        model = Medicine
        # Trả về các trường này khi đọc
        fields = ['id', 'name', 'unit', 'description','stock_quantity']


# <<< SỬA LẠI HOÀN TOÀN `PrescriptionItemSerializer` >>>
class PrescriptionItemSerializer(serializers.ModelSerializer):
    # Thêm trường này để hiển thị thông tin chi tiết của thuốc khi ĐỌC
    medicine_details = MedicineSerializer(source='medicine', read_only=True)

    class Meta:
        model = PrescriptionItem
        # `medicine` sẽ được dùng để GHI (nhận ID), còn `medicine_details` để ĐỌC
        fields = ['id', 'medicine', 'medicine_details', 'dosage', 'quantity']
        extra_kwargs = {
            'medicine': {'write_only': True}
        }


# <<< SỬA LẠI HOÀN TOÀN `PrescriptionSerializer` >>>
class PrescriptionSerializer(serializers.ModelSerializer):
    # Cho phép ghi và đọc dữ liệu lồng nhau cho 'items'
    items = PrescriptionItemSerializer(many=True)

    class Meta:
        model = Prescription
        # 'encounter' sẽ được cung cấp từ bên ngoài, client không cần gửi
        fields = ['id', 'notes', 'items']


# <<< SỬA LẠI HOÀN TOÀN `EncounterSerializer` >>>
class EncounterSerializer(serializers.ModelSerializer):
    # Cho phép ghi và đọc dữ liệu lồng nhau cho 'prescriptions'
    prescriptions = PrescriptionSerializer(many=True, required=False)
    services_performed_details = ServiceSerializer(source='services_performed', many=True, read_only=True)

    # Các trường chỉ đọc để hiển thị thông tin thêm
    patient_name = serializers.CharField(source='appointment.patient.get_full_name', read_only=True)
    doctor_name = serializers.CharField(source='appointment.doctor.get_full_name', read_only=True)
    appointment_time = serializers.DateTimeField(source='appointment.appointment_time', read_only=True)
    patient_id = serializers.IntegerField(source='appointment.patient.id', read_only=True)
    specialty_name = serializers.CharField(source='appointment.doctor.doctor_profile.specialty.name', read_only=True, allow_null=True)
    
    reason_why = serializers.CharField(source='appointment.reason', read_only=True, allow_null=True)


    class Meta:
        model = Encounter
        fields = [
            'id', 'appointment', 'symptoms', 'diagnosis', 'prescriptions',
            'patient_name', 'doctor_name', 'appointment_time', 'patient_id',
            'reason_why','specialty_name', 'services_performed_details','services_performed',

        ]

        extra_kwargs = {
            # Trường này chỉ dùng để nhận dữ liệu, không cần hiển thị ID thô
            'services_performed': {'write_only': True}
        }

    def create(self, validated_data):
        # Tách các dữ liệu lồng nhau (nested data) ra khỏi validated_data
        prescriptions_data = validated_data.pop('prescriptions', [])
        services_data = validated_data.pop('services_performed', [])
        
        # 1. Tạo đối tượng Encounter chính với các trường đơn giản trước
        encounter = Encounter.objects.create(**validated_data)

        # 2. Gán các mối quan hệ Many-to-Many sau khi đã có `encounter`
        if services_data:
            encounter.services_performed.set(services_data)

        # 3. Xử lý tạo các đơn thuốc (Prescription)
        # (Giữ nguyên logic tạo đơn thuốc nếu bạn đã có)
        for prescription_data in prescriptions_data:
            items_data = prescription_data.pop('items', [])
            prescription = Prescription.objects.create(encounter=encounter, **prescription_data)
            for item_data in items_data:
                PrescriptionItem.objects.create(prescription=prescription, **item_data)
        
        return encounter




class SpecialtySerializer(serializers.ModelSerializer):
    """
    Serializer cho model Chuyên khoa.
    """
    class Meta:
        model = Specialty
        fields = ['id', 'name'] # Chỉ cần trả về ID và Tên là đủ

class StockTransactionSerializer(serializers.ModelSerializer):
    # Lấy tên thuốc thay vì ID
    medicine_name = serializers.CharField(source='medicine.name', read_only=True)
    # Lấy username người thực hiện thay vì ID
    created_by_username = serializers.CharField(source='created_by.username', read_only=True, allow_null=True)
    # Lấy tên hiển thị của loại giao dịch
    transaction_type_display = serializers.CharField(source='get_transaction_type_display', read_only=True)

    class Meta:
        model = StockTransaction
        fields = [
            'id',
            'medicine_name',
            'transaction_type',
            'transaction_type_display',
            'quantity',
            'notes',
            'created_by_username',
            'created_at'
        ]

class StockTransactionVoucherItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = StockTransaction
        fields = ['medicine', 'quantity', 'notes']


# Serializer chính cho Phiếu Kho
class StockVoucherSerializer(serializers.ModelSerializer):
    # Dùng để xử lý việc tạo các transaction lồng nhau
    transactions = StockTransactionVoucherItemSerializer(many=True, write_only=True)
    
    # Các trường chỉ đọc để hiển thị thông tin
    created_by_username = serializers.CharField(source='created_by.username', read_only=True, allow_null=True)
    voucher_type_display = serializers.CharField(source='get_voucher_type_display', read_only=True)
    
    class Meta:
        model = StockVoucher
        fields = [
            'id', 'voucher_type', 'voucher_type_display', 'reason', 
            'created_by_username', 'created_at', 'transactions'
        ]

    # Ghi đè hàm create để xử lý logic phức tạp
    def create(self, validated_data):
        transactions_data = validated_data.pop('transactions')
        
        with transaction.atomic():
            # 1. Tạo Phiếu
            voucher = StockVoucher.objects.create(**validated_data)

            # 2. Lặp qua từng dòng, tạo Transaction và cập nhật kho
            for trans_data in transactions_data:
                medicine = trans_data['medicine']
                quantity = trans_data['quantity']
                
                # Xác định loại giao dịch và số lượng (dương/âm)
                if voucher.voucher_type == StockVoucher.VoucherType.STOCK_IN:
                    trans_type = StockTransaction.TransactionType.VOUCHER_IN
                    quantity_change = quantity
                else: # STOCK_OUT
                    trans_type = StockTransaction.TransactionType.VOUCHER_OUT
                    quantity_change = -quantity
                    
                    # Kiểm tra tồn kho trước khi xuất
                    if medicine.stock_quantity < quantity:
                        raise serializers.ValidationError(f"Không đủ tồn kho cho thuốc '{medicine.name}'.")

                # Cập nhật số lượng thuốc
                medicine.stock_quantity += quantity_change
                medicine.save()

                # Tạo bản ghi giao dịch
                StockTransaction.objects.create(
                    voucher=voucher,
                    medicine=medicine,
                    quantity=quantity_change,
                    notes=trans_data.get('notes', ''),
                    transaction_type=trans_type,
                    created_by=validated_data.get('created_by')
                )
                
        return voucher


class StockReportPointSerializer(serializers.Serializer):
    date = serializers.DateField()
    stock_in = serializers.IntegerField()
    stock_out_manual = serializers.IntegerField()
    stock_out_prescription = serializers.IntegerField()


