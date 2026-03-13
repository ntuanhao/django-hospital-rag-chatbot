
# api/views.py

from django.utils import timezone
from django.db import transaction
from rest_framework import viewsets, generics, permissions as drf_perms, status
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny
from django.contrib.auth.hashers import check_password
from rest_framework_simplejwt.tokens import RefreshToken

from datetime import datetime, date, time, timedelta

from rest_framework import permissions
from rest_framework.exceptions import ValidationError
from rest_framework.permissions import OR

from django_filters.rest_framework import DjangoFilterBackend

from django_filters import rest_framework as django_filters
from rest_framework import filters

from django.db.models import Count,Sum,Case, When, IntegerField
from django.db.models.functions import TruncDate

import pandas as pd


# Models / Serializers
from .models import (
    UserAccount, Specialty, Service, RecurringSchedule,
    Appointment, Encounter, Prescription,Medicine, StockTransaction,PrescriptionItem
)

from .serializers import *

# Permissions (đã sửa trong permissions.py)
from .permissions import (
    IsPatientUser, IsReceptionistUser, IsDoctorUser, IsAppAdminUser,IsDoctorOrIsAppAdminUser
)


# ---------------------------------------------------------------------
# Helper: map từ Django User -> UserAccount (theo username)
# Nếu bạn đã liên kết OneToOne(UserAccount.user), có thể đổi sang:
#   return getattr(request.user, "useraccount", None)
# ---------------------------------------------------------------------
def get_current_account(request):
    username = getattr(request.user, "username", None)
    if not username:
        return None
    return UserAccount.objects.filter(username=username, is_active=True).first()

def get_current_role(request):
    acc = get_current_account(request)
    return acc.role if acc else None


# ==========================
# Auth views
# ==========================

class UserAccountLoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        username = request.data.get("username")
        password = request.data.get("password")
        try:
            user = UserAccount.objects.get(username=username, is_active=True)
        except UserAccount.DoesNotExist:
            return Response({"detail": "Tài khoản không tồn tại hoặc chưa được kích hoạt."},
                            status=status.HTTP_401_UNAUTHORIZED)
        if not check_password(password, user.password):
            return Response({"detail": "Sai mật khẩu"}, status=status.HTTP_401_UNAUTHORIZED)

        refresh = RefreshToken.for_user(user)
        return Response(
            {"refresh": str(refresh), "access": str(refresh.access_token),
             "user_id": user.id, "role": user.role},
            status=status.HTTP_200_OK
        )


class RegisterView(generics.CreateAPIView):
    queryset = UserAccount.objects.all()
    permission_classes = [AllowAny]
    serializer_class = RegisterSerializer


# ==========================
# User CRUD
# ==========================

class UserViewSet(viewsets.ModelViewSet):
    queryset = UserAccount.objects.filter(is_active=True)
    permission_classes = [drf_perms.IsAuthenticated]
    filter_backends = [filters.SearchFilter]
    search_fields = ['username', 'first_name', 'last_name', 'phone_number', 'email']
    
    # filterset_fields = ['role', 'doctor_profile__specialty']


    def get_serializer_class(self):
        if self.action == 'create':
            return AdminCreateUserSerializer
        if self.action == 'me' and self.request.method in ['PUT', 'PATCH']:
            return UserAccountUpdateSerializer
        if self.action == 'set_password':
            return ChangePasswordSerializer
        return UserAccountSerializer


    def get_queryset(self):
        queryset = super().get_queryset()
        user = get_current_account(self.request)
        
        # if self.action == 'list':
        #     if user and user.role == UserAccount.Role.ADMIN:
        #         return queryset

        #     role_to_filter = self.request.query_params.get('role')
        #     if role_to_filter:
        #         role_upper = role_to_filter.upper()
        #         if role_upper == UserAccount.Role.DOCTOR:
        #             qs = queryset.filter(role=UserAccount.Role.DOCTOR)

        #             specialty_filter_id = self.request.query_params.get('doctor_profile_specialty')
        #             if specialty_filter_id:
        #                 # thử filter bằng doctor_profile trước
        #                 try:
        #                     qs = qs.filter(doctor_profile__specialty_id=specialty_filter_id)
        #                     if not qs.exists():
        #                         # fallback nếu model dùng related_name='profile'
        #                         qs = queryset.filter(profile__specialty_id=specialty_filter_id)
        #                 except Exception:
        #                     # fallback an toàn
        #                     qs = queryset.filter(profile__specialty_id=specialty_filter_id)

        #             return qs
                
        #         elif role_upper == UserAccount.Role.PATIENT:
        #             if user and user.role in [UserAccount.Role.RECEPTIONIST, UserAccount.Role.ADMIN]:
        #                 return queryset.filter(role=UserAccount.Role.PATIENT)
        #             else:
        #                 return queryset.none()

        #     return queryset.filter(id=user.id) if user else queryset.none()
        
        # return queryset
        if self.action != 'list':
            return queryset

        # Lấy các tham số lọc từ URL (VD: ?role=DOCTOR&search=Vinh)
        role_filter = self.request.query_params.get('role')
        specialty_filter_id = self.request.query_params.get('doctor_profile_specialty')

        # === LOGIC MỚI CHO ADMIN ===
        if user and user.role == UserAccount.Role.ADMIN:
            # 1. Áp dụng bộ lọc vai trò (nếu có)
            if role_filter:
                queryset = queryset.filter(role=role_filter.upper())
            
            # 2. Áp dụng bộ lọc chuyên khoa (nếu lọc bác sĩ)
            if role_filter and role_filter.upper() == 'DOCTOR' and specialty_filter_id:
                queryset = queryset.filter(doctor_profile__specialty_id=specialty_filter_id)

            # 3. Trả về queryset đã được lọc cho Admin
            return queryset

        # === LOGIC CŨ CỦA BẠN CHO CÁC VAI TRÒ KHÁC (GIỮ NGUYÊN) ===
        # Bệnh nhân hoặc Lễ tân xem danh sách bác sĩ
        if role_filter and role_filter.upper() == 'DOCTOR':
            qs = queryset.filter(role=UserAccount.Role.DOCTOR)
            if specialty_filter_id:
                qs = qs.filter(doctor_profile__specialty_id=specialty_filter_id)
            return qs
        
        # Lễ tân xem danh sách bệnh nhân
        if role_filter and role_filter.upper() == 'PATIENT':
            if user and user.role == UserAccount.Role.RECEPTIONIST:
                return queryset.filter(role=UserAccount.Role.PATIENT)
            else:
                return queryset.none() # Các vai trò khác không được xem danh sách bệnh nhân

        # Mặc định, nếu không có bộ lọc nào, người dùng chỉ thấy chính mình
        return queryset.filter(id=current_user.id) if current_user else queryset.none()

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            # Chỉ Admin mới được tạo/sửa/xoá user khác
            if self.kwargs.get('pk') != str(self.request.user.pk):
                self.permission_classes = [IsAppAdminUser]
        return super().get_permissions()
    
    @action(detail=True, methods=['get']) # detail=True nghĩa là nó sẽ có URL /api/users/{pk}/services/
    def services(self, request, pk=None):
        """
        Trả về danh sách các dịch vụ mà một bác sĩ cụ thể cung cấp,
        dựa trên chuyên khoa của họ.
        """
        try:
            # Lấy bác sĩ dựa trên pk từ URL
            doctor = UserAccount.objects.get(pk=pk, role=UserAccount.Role.DOCTOR)
            # Lấy chuyên khoa của bác sĩ
            specialty = doctor.doctor_profile.specialty
            if not specialty:
                return Response([], status=status.HTTP_200_OK)
            
            # Lấy tất cả dịch vụ thuộc chuyên khoa đó
            services = specialty.services.all()
            serializer = ServiceSerializer(services, many=True)
            return Response(serializer.data)
        except UserAccount.DoesNotExist:
            return Response({"error": "Bác sĩ không tồn tại."}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=False, methods=['get', 'put', 'patch'], url_path='me')
    def me(self, request, *args, **kwargs):
        self.kwargs['pk'] = request.user.pk
        if request.method == 'GET':
            return self.retrieve(request, *args, **kwargs)
        elif request.method == 'PUT':
            return self.update(request, *args, **kwargs)
        elif request.method == 'PATCH':
            return self.partial_update(request, *args, **kwargs)

    @action(detail=False, methods=['post'], url_path='set-password')
    def set_password(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({"detail": "Mật khẩu đã được thay đổi thành công."}, status=status.HTTP_200_OK)


    @transaction.atomic
    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object()

        # cập nhật phần UserAccount chính
        user_serializer = self.get_serializer(instance, data=request.data, partial=partial)
        user_serializer.is_valid(raise_exception=True)
        user_serializer.save()

        # cập nhật phần profile theo vai trò (nếu client gửi "profile": {...})
        profile_data = request.data.get('profile', {})
        if profile_data:
            profile_instance, ProfileSerializer = None, None

            if instance.role == UserAccount.Role.PATIENT:
                from .serializers import PatientProfileSerializer
                from .models import PatientProfile
                ProfileSerializer = PatientProfileSerializer
                profile_instance = getattr(instance, 'patient_profile', None)
                if profile_instance is None:
                    profile_instance = PatientProfile.objects.create(user=instance)

            elif instance.role == UserAccount.Role.DOCTOR:
                from .serializers import DoctorProfileSerializer
                from .models import DoctorProfile
                ProfileSerializer = DoctorProfileSerializer
                profile_instance = getattr(instance, 'doctor_profile', None)
                if profile_instance is None:
                    doctor_profile = DoctorProfile.objects.create(user=instance)
                    profile_instance = doctor_profile

            elif instance.role == UserAccount.Role.RECEPTIONIST:
                from .serializers import ReceptionistProfileSerializer
                from .models import ReceptionistProfile
                ProfileSerializer = ReceptionistProfileSerializer
                profile_instance = getattr(instance, 'receptionist_profile', None)
                if profile_instance is None:
                    profile_instance = ReceptionistProfile.objects.create(user=instance)

            if profile_instance and ProfileSerializer:
                profile_serializer = ProfileSerializer(
                    profile_instance, data=profile_data, partial=partial
                )
                profile_serializer.is_valid(raise_exception=True)
                profile_serializer.save()

        return Response(UserAccountSerializer(instance, context={'request': request}).data)


    def partial_update(self, request, *args, **kwargs):
        kwargs['partial'] = True
        return self.update(request, *args, **kwargs)
    
    @action(detail=False, methods=['get'], permission_classes=[IsDoctorUser])
    def my_patients(self, request):
        """
        Action dành riêng cho Bác sĩ để lấy danh sách các bệnh nhân
        mà họ đã từng có lịch hẹn.
        """
        doctor = get_current_account(request)
        if not doctor:
            return Response([], status=status.HTTP_200_OK)

        # Lấy ra ID của tất cả các bệnh nhân đã có lịch hẹn với bác sĩ này
        patient_ids = Appointment.objects.filter(doctor=doctor).values_list('patient_id', flat=True).distinct()

        # Lấy thông tin chi tiết của các bệnh nhân đó
        patients = UserAccount.objects.filter(id__in=patient_ids)

        # Serialize dữ liệu và trả về
        serializer = self.get_serializer(patients, many=True)
        return Response(serializer.data)


# ==========================
# Specialty / Service
# ==========================


class SpecialtyViewSet(viewsets.ModelViewSet):
    """
    ViewSet để quản lý Chuyên khoa.
    - Ai cũng có thể đọc danh sách.
    - Chỉ Admin có thể tạo/sửa/xóa.
    """
    queryset = Specialty.objects.all().order_by('name')
    serializer_class = SpecialtySerializer
    
    # Thiết lập quyền hạn động
    def get_permissions(self):
        # Nếu hành động là 'list' hoặc 'retrieve' (xem danh sách hoặc chi tiết)
        if self.action in ['list', 'retrieve']:
            # Thì chỉ cần đã đăng nhập là được
            self.permission_classes = [permissions.IsAuthenticated]
        else:
            # Đối với các hành động khác (create, update, destroy), yêu cầu phải là Admin
            self.permission_classes = [IsAppAdminUser]
        return super().get_permissions()


class ServiceViewSet(viewsets.ModelViewSet):
    queryset = Service.objects.all()
    serializer_class = ServiceSerializer
    filterset_fields = ['specialties']

    
    def get_queryset(self):
        queryset = Service.objects.all().order_by('name')
        
        # Lọc thủ công theo chuyên khoa từ query params
        specialty_id = self.request.query_params.get('specialty_id')
        if specialty_id:
            # Lọc các service có specialties chứa ID này
            queryset = queryset.filter(specialties__id=specialty_id)
            
        return queryset
    
    def get_permissions(self):
        # Nếu hành động là 'list' hoặc 'retrieve' (xem)
        if self.action in ['list', 'retrieve']:
            # Thì chỉ cần đã đăng nhập là được
            self.permission_classes = [permissions.IsAuthenticated]
        else:
            # Đối với các hành động khác (create, update, destroy), yêu cầu phải là Admin
            self.permission_classes = [IsAppAdminUser]
        return super().get_permissions()


# ==========================
# Recurring Schedules (read-only)
# ==========================

class RecurringScheduleViewSet(viewsets.ModelViewSet): # Sửa từ ReadOnlyModelViewSet
    serializer_class = RecurringScheduleSerializer
    permission_classes = [drf_perms.IsAuthenticated]

    # Hàm get_queryset vẫn giữ nguyên logic cũ
    def get_queryset(self):
        user = get_current_account(self.request)
        if not user:
            return RecurringSchedule.objects.none()

        if user.role == UserAccount.Role.DOCTOR:
            return RecurringSchedule.objects.filter(doctor=user)

        doctor_id = self.request.query_params.get('doctor_id')
        if doctor_id is not None:
            return RecurringSchedule.objects.filter(doctor__id=doctor_id)
        
        if user.role == UserAccount.Role.ADMIN:
            return RecurringSchedule.objects.all()

        return RecurringSchedule.objects.none()

    # <<< THÊM HÀM MỚI ĐỂ PHÂN QUYỀN ĐỘNG >>>
    def get_permissions(self):
        # Nếu hành động là xem (list, retrieve)
        if self.action in ['list', 'retrieve']:
            self.permission_classes = [drf_perms.IsAuthenticated]
        # Đối với các hành động khác (tạo, sửa, xóa)
        else:
            self.permission_classes = [IsAppAdminUser] # Chỉ Admin mới được thực hiện
        return super().get_permissions()


# ==========================
# Appointment
# ==========================
class AppointmentFilter(django_filters.FilterSet):
    # Lọc theo khoảng ngày
    start_date = django_filters.DateFilter(field_name="appointment_time__date", lookup_expr='gte')
    end_date = django_filters.DateFilter(field_name="appointment_time__date", lookup_expr='lte')

    class Meta:
        model = Appointment
        fields = ['doctor', 'patient', 'status', 'start_date', 'end_date']



class AppointmentViewSet(viewsets.ModelViewSet):
    serializer_class = AppointmentSerializer
    permission_classes = [drf_perms.IsAuthenticated]

    # <<< BỔ SUNG CÁC BỘ LỌC MÀ KHÔNG THAY ĐỔI QUERYSET >>>
    filter_backends = [django_filters.DjangoFilterBackend]
    filterset_class = AppointmentFilter
    

    # <<< HÀM GET_QUERYSET GẦN NHƯ GIỮ NGUYÊN HOÀN TOÀN >>>
    def get_queryset(self):
        me = get_current_account(self.request)
        if not me:
            return Appointment.objects.none()
        
        # === THAY ĐỔI DUY NHẤT VÀ AN TOÀN NHẤT LÀ Ở ĐÂY ===
        # Nếu là Admin, trả về TẤT CẢ. Django-filter sẽ xử lý phần còn lại.
        # Các vai trò khác vẫn có queryset bị giới hạn như cũ.
        if me.role == UserAccount.Role.ADMIN:
            return Appointment.objects.all()

        # === PHẦN CODE CŨ CỦA BẠN - GIỮ NGUYÊN 100% ===
        # Logic này vẫn hoạt động cho Lễ tân, Bác sĩ, Bệnh nhân
        doctor_id = self.request.query_params.get('doctor_id')
        if doctor_id is not None:
            # Đảm bảo chỉ trả về lịch của bác sĩ đó cho các vai trò được phép
            if me.role == UserAccount.Role.RECEPTIONIST:
                 return Appointment.objects.filter(doctor__id=doctor_id)
            # Các vai trò khác sẽ rơi vào các điều kiện bên dưới
        
        if me.role == UserAccount.Role.PATIENT:
            return Appointment.objects.filter(patient=me)
        
        if me.role == UserAccount.Role.DOCTOR:
            return Appointment.objects.filter(doctor=me)
        
        if me.role == UserAccount.Role.RECEPTIONIST:
            # Mặc định, Lễ tân thấy tất cả (nếu không có doctor_id)
            return Appointment.objects.all()

        return Appointment.objects.none()

    def get_permissions(self):
        if self.action == 'create':
            # ✅ Combine bằng CLASS rồi mới khởi tạo ()
            return [(IsPatientUser | IsReceptionistUser | IsAppAdminUser)()]
        return [drf_perms.IsAuthenticated()]
    
    

    @transaction.atomic
    def perform_create(self, serializer):
        current_account = get_current_account(self.request)
        if not current_account:
            raise ValidationError("Không thể xác thực người dùng hiện tại.")

        # Lấy thông tin thời điểm khám/bác sĩ từ payload đã validate
        start_at = serializer.validated_data['appointment_time']  # DateTime
        doctor   = serializer.validated_data['doctor']
        slot_minutes = serializer.validated_data.get('duration_minutes', 30)  # mặc định 30’
        end_at = start_at + timedelta(minutes=slot_minutes)

        BUSY = [
            Appointment.Status.PATIENT_REQUESTED,
            Appointment.Status.RECEPTIONIST_PROPOSED,
            Appointment.Status.CONFIRMED,
            Appointment.Status.CHECKED_IN,
        ]

        # Khóa hàng và kiểm tra overlap (nếu dùng end_time thì dùng khoảng; nếu 1 slot = 1 start_at thì check equal)
        conflict = Appointment.objects.select_for_update().filter(
            doctor=doctor,
            appointment_time__lt=end_at,
            appointment_time__gte=start_at - timedelta(minutes=slot_minutes-1),
            status__in=BUSY,
        ).exists()

        if conflict:
            raise ValidationError("Khung giờ này đã có người đặt. Vui lòng chọn khung khác.")

        # Không conflict -> cho tạo như cũ
        if current_account.role == UserAccount.Role.PATIENT:
            serializer.save(patient=current_account, created_by=current_account,
                            status=Appointment.Status.PATIENT_REQUESTED)
        elif current_account.role in [UserAccount.Role.RECEPTIONIST, UserAccount.Role.ADMIN]:
            if 'patient' not in serializer.validated_data:
                raise ValidationError({"patient_id": ["Trường này là bắt buộc."]})
            serializer.save(created_by=current_account,
                            status=Appointment.Status.RECEPTIONIST_PROPOSED)
        else:
            raise ValidationError("Vai trò của bạn không được phép tạo lịch hẹn.")

    def _update_status(self, request, appointment, new_status):
        serializer = AppointmentStatusUpdateSerializer(appointment, data={'status': new_status})
        serializer.is_valid(raise_exception=True)
        serializer.save()

        me = get_current_account(request)
        if new_status == Appointment.Status.CONFIRMED:
            if me and me.role in [UserAccount.Role.RECEPTIONIST, UserAccount.Role.ADMIN]:
                appointment.receptionist_confirmed_by = me
            else:
                appointment.patient_confirmed_at = timezone.now()
            appointment.save()

        return Response({'status': f'Trạng thái lịch hẹn đã được cập nhật thành {new_status}'},
                        status=status.HTTP_200_OK)

    @action(detail=True, methods=['post'], permission_classes=[drf_perms.IsAuthenticated])
    def cancel(self, request, pk=None):
        appointment = self.get_object()
        me = get_current_account(request)

        is_patient_owner = me and me.role == UserAccount.Role.PATIENT and appointment.patient == me
        is_staff = me and me.role in [UserAccount.Role.RECEPTIONIST, UserAccount.Role.ADMIN]

        if not (is_patient_owner or is_staff):
            return Response({'error': 'Bạn không có quyền hủy lịch hẹn này'}, status=status.HTTP_403_FORBIDDEN)
        if appointment.status in [Appointment.Status.COMPLETED, Appointment.Status.CANCELLED]:
            return Response({'error': 'Không thể hủy lịch hẹn đã hoàn thành hoặc đã bị hủy từ trước.'},
                            status=status.HTTP_400_BAD_REQUEST)
        return self._update_status(request, appointment, Appointment.Status.CANCELLED)
    

    @action(detail=False, methods=['get'], url_path='available-slots',
            permission_classes=[drf_perms.IsAuthenticated])
    def available_slots(self, request):
        """
        Trả về danh sách slot còn trống cho 1 bác sĩ trong 1 ngày.
        query: doctor_id, date=YYYY-MM-DD, slot_minutes=30, start_hour=8, end_hour=17
        """
        try:
            doctor_id = int(request.query_params.get('doctor_id'))
            day = date.fromisoformat(request.query_params.get('date'))  # YYYY-MM-DD
        except Exception:
            return Response({"detail": "Thiếu hoặc sai định dạng doctor_id/date"}, status=400)

        slot_minutes = int(request.query_params.get('slot_minutes', 30))
        start_hour   = int(request.query_params.get('start_hour', 8))
        end_hour     = int(request.query_params.get('end_hour', 17))

        tz = timezone.get_current_timezone()
        start_dt = tz.localize(datetime.combine(day, time(hour=start_hour)))
        end_dt   = tz.localize(datetime.combine(day, time(hour=end_hour)))

        # Các trạng thái “chiếm chỗ” (đã/đang đặt)
        BUSY = [
            Appointment.Status.PATIENT_REQUESTED,
            Appointment.Status.RECEPTIONIST_PROPOSED,
            Appointment.Status.CONFIRMED,
            Appointment.Status.CHECKED_IN,
        ]

        # Lấy toàn bộ hẹn trong khung ngày đó
        busy_qs = Appointment.objects.filter(
            doctor_id=doctor_id,
            appointment_time__gte=start_dt,
            appointment_time__lt=end_dt,
            status__in=BUSY,
        ).values_list('appointment_time', flat=True)

        busy_set = {dt.astimezone(tz).replace(second=0, microsecond=0) for dt in busy_qs}

        # Sinh toàn bộ slot rồi lọc ra những slot KHÔNG nằm trong busy_set
        slots, cur = [], start_dt
        while cur < end_dt:
            if cur not in busy_set:  # nếu 1 lịch khám = 1 slot cố định
                slots.append(cur.isoformat())
            cur += timedelta(minutes=slot_minutes)

        return Response({"doctor_id": doctor_id, "date": day.isoformat(), "slot_minutes": slot_minutes, "available": slots})


    #lễ tân xác nhận
    @action(
        detail=True, methods=['post'],
        permission_classes=[(IsReceptionistUser | IsAppAdminUser)()]
    )
    def receptionist_confirm(self, request, pk=None):
        appointment = self.get_object()

        if appointment.status != Appointment.Status.PATIENT_REQUESTED:
            return Response(
                {'error': 'Chỉ xác nhận lịch ở trạng thái bệnh nhân đã yêu cầu (PATIENT_REQUESTED).'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Dùng helper có sẵn để cập nhật và tự set receptionist_confirmed_by
        return self._update_status(request, appointment, Appointment.Status.CONFIRMED)

    @action(
        detail=True, methods=['post'],
        permission_classes=[(IsReceptionistUser | IsAppAdminUser)()]
    )
    def confirm(self, request, pk=None):
        appointment = self.get_object()

        note = (request.data.get('note') or request.data.get('reason') or '').strip()
        if note:
            appointment.reception_notes = note
            appointment.save(update_fields=['reception_notes'])

        if appointment.status != Appointment.Status.PATIENT_REQUESTED:
            return Response(
                {'error': 'Chỉ xác nhận lịch ở trạng thái PATIENT_REQUESTED.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        return self._update_status(request, appointment, Appointment.Status.CONFIRMED)

    # ✅ Lễ tân từ chối lịch hẹn
    @action(
        detail=True, methods=['post'],
        permission_classes=[(IsReceptionistUser | IsAppAdminUser)()]
    )
    def reject(self, request, pk=None):
        appointment = self.get_object()
        serializer = AppointmentRejectSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        appointment.reception_notes = serializer.validated_data['reason']
        appointment.save(update_fields=['reception_notes'])


        if appointment.status not in [
            Appointment.Status.PATIENT_REQUESTED,
            Appointment.Status.RECEPTIONIST_PROPOSED,
        ]:
            return Response({'error': 'Chỉ có thể từ chối lịch đang chờ xử lý.'},
                            status=status.HTTP_400_BAD_REQUEST)

        appointment.reception_notes = serializer.validated_data['reason']
        appointment.save()
        return self._update_status(request, appointment, Appointment.Status.REJECTED)

    #bệnh nhân xác nhận
    @action(detail=True, methods=['post'], permission_classes=[drf_perms.IsAuthenticated])
    def patient_confirm(self, request, pk=None):
        appointment = self.get_object()
        me = get_current_account(request)

        if not me or me.role != UserAccount.Role.PATIENT or appointment.patient != me:
            return Response({'error': 'Chỉ bệnh nhân của lịch hẹn mới được xác nhận.'},
                        status=status.HTTP_403_FORBIDDEN)

        if appointment.status != Appointment.Status.RECEPTIONIST_PROPOSED:
            return Response({'error': 'Chỉ xác nhận lịch ở trạng thái RECEPTIONIST_PROPOSED.'},
                        status=status.HTTP_400_BAD_REQUEST)

        return self._update_status(request, appointment, Appointment.Status.CONFIRMED)

    #check-in
    @action(
        detail=True, 
        methods=['post'],
        # Chỉ Lễ tân hoặc Admin mới có quyền check-in
        
    )
    def check_in(self, request, pk=None):
        """
        Action cho Lễ tân check-in cho bệnh nhân khi họ đến khám.
        """
        appointment = self.get_object()
        
        # <<< THÊM ĐIỀU KIỆN KIỂM TRA NGÀY Ở ĐÂY >>>
        # Lấy ngày hiện tại (chỉ phần ngày, không tính giờ)
        today_local = timezone.localtime(timezone.now()).date()
        appointment_date = appointment.appointment_time.date()

        # Kiểm tra xem hôm nay có phải là ngày hẹn không
        if appointment_date != today_local:
            return Response({'error': f'Chỉ có thể check-in vào đúng ngày hẹn ({appointment_date.strftime("%d/%m/%Y")}).'}, status=status.HTTP_400_BAD_REQUEST)

        # Kiểm tra trạng thái
        if appointment.status != Appointment.Status.CONFIRMED:
            return Response({'error': 'Chỉ có thể check-in cho lịch hẹn đã được xác nhận.'}, status=status.HTTP_400_BAD_REQUEST)
        
        return self._update_status(request, appointment, Appointment.Status.CHECKED_IN)

    @action(
        detail=True, 
        methods=['post'],
        
    )
    def complete(self, request, pk=None):
        """
        Action để đánh dấu một cuộc hẹn đã hoàn thành khám.
        """
        appointment = self.get_object()
        
        # Chỉ có thể hoàn thành một lịch hẹn đã check-in
        if appointment.status != Appointment.Status.CHECKED_IN:
            return Response({'error': 'Chỉ có thể hoàn thành lịch hẹn đã check-in.'}, status=status.HTTP_400_BAD_REQUEST)
            
        # Việc kiểm tra ngày là không cần thiết ở đây, vì để có trạng thái CHECKED_IN,
        # nó đã phải đi qua bước check-in (đã kiểm tra ngày).
        
        return self._update_status(request, appointment, Appointment.Status.COMPLETED)

# ==========================
# Encounter
# ==========================

class EncounterViewSet(viewsets.ModelViewSet):
    serializer_class = EncounterSerializer
    permission_classes = [drf_perms.IsAuthenticated]

    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['appointment__patient']

    def get_queryset(self):
        me = get_current_account(self.request)
        if not me:
            return Encounter.objects.none()
        # Bệnh nhân chỉ xem được của mình (không đổi)
        if me.role == UserAccount.Role.PATIENT:
            return Encounter.objects.filter(appointment__patient=me)
        if me.role == UserAccount.Role.DOCTOR:
            return Encounter.objects.filter(appointment__doctor=me)
        if me.role == UserAccount.Role.ADMIN:
            return Encounter.objects.all()
        return Encounter.objects.all()

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsDoctorUser()]
        return [drf_perms.IsAuthenticated()]
    

    @transaction.atomic
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        prescriptions_data = serializer.validated_data.pop('prescriptions', [])

        # 1. KIỂM TRA TỒN KHO (Không thay đổi)
        for prescription_data in prescriptions_data:
            for item_data in prescription_data.get('items', []):
                medicine = item_data['medicine']
                quantity_to_prescribe = item_data['quantity']
                
                medicine_to_check = Medicine.objects.select_for_update().get(pk=medicine.pk)
                
                if medicine_to_check.stock_quantity < quantity_to_prescribe:
                    raise ValidationError(
                        f"Không đủ thuốc '{medicine_to_check.name}' trong kho. "
                        f"Chỉ còn {medicine_to_check.stock_quantity} {medicine_to_check.unit}."
                    )

        # 2. TẠO BỆNH ÁN
        # `serializer.save()` sẽ tự động tạo object Encounter
        # Dữ liệu `prescriptions` đã được pop ra nên sẽ không bị xử lý bởi serializer
        encounter = serializer.save()

        # 3. TẠO ĐƠN THUỐC, TRỪ KHO VÀ GHI LỊCH SỬ
        for prescription_data in prescriptions_data:
            items_data = prescription_data.pop('items', [])
            prescription = Prescription.objects.create(encounter=encounter, **prescription_data)
            
            for item_data in items_data:
                medicine = item_data['medicine']
                quantity_to_prescribe = item_data['quantity']
                
                # Tạo chi tiết đơn thuốc
                PrescriptionItem.objects.create(prescription=prescription, **item_data)
                
                # Trừ số lượng trong kho
                medicine.stock_quantity -= quantity_to_prescribe
                medicine.save(update_fields=['stock_quantity'])

                # ==========================================================
                # <<< === THAY ĐỔI CHÍNH NẰM Ở ĐÂY === >>>
                # ==========================================================
                # Tự động tạo một bản ghi giao dịch kho cho việc kê đơn
                StockTransaction.objects.create(
                    medicine=medicine,
                    transaction_type=StockTransaction.TransactionType.PRESCRIPTION,
                    quantity=-quantity_to_prescribe, # Ghi số lượng xuất là số âm
                    notes=f"Kê đơn cho bệnh án #{encounter.id} của bệnh nhân {encounter.appointment.patient.get_full_name()}",
                    created_by=get_current_account(request) # Lấy tài khoản bác sĩ đang thực hiện
                )
                # ==========================================================
        
        # 4. TRẢ VỀ RESPONSE (Không thay đổi)
        # Sử dụng serializer để trả về dữ liệu bệnh án hoàn chỉnh
        return Response(EncounterSerializer(instance=encounter, context={'request': request}).data, status=status.HTTP_201_CREATED)
    

# ==========================
# Medicine
# ==========================    

class MedicineViewSet(viewsets.ModelViewSet):
    """
    ViewSet chỉ cho phép đọc và tìm kiếm danh mục thuốc.
    Chỉ Bác sĩ (hoặc các nhân viên y tế) mới có quyền truy cập.
    """
    queryset = Medicine.objects.all().order_by('name')
    serializer_class = MedicineSerializer
    # Chỉ Bác sĩ và Admin mới được xem/tìm kiếm thuốc
    # permission_classes = [OR(IsDoctorUser(), IsAppAdminUser())]
    permission_classes = [IsDoctorOrIsAppAdminUser]
    # Kích hoạt bộ lọc tìm kiếm
    filter_backends = [filters.SearchFilter]
    search_fields = ['name'] # Cho phép tìm thuốc theo tên

    def get_permissions(self):
        # Nếu hành động là xem hoặc tìm kiếm
        if self.action in ['list', 'retrieve']:
            self.permission_classes = [IsDoctorOrIsAppAdminUser]
        # Đối với các hành động khác (tạo, sửa, xóa)
        else:
            self.permission_classes = [IsAppAdminUser]
        return super().get_permissions()

    # <<< ACTION MỚI CHO VIỆC NHẬP KHO >>>
    @action(detail=True, methods=['post'], permission_classes=[IsAppAdminUser])
    def add_stock(self, request, pk=None):
        """
        Action cho Admin để cộng thêm số lượng vào kho cho một loại thuốc.
        Payload: {'quantity': 50}
        """
        try:
            quantity_to_add = int(request.data.get('quantity', 0))
            notes = request.data.get('notes', 'Nhập kho thủ công')
            
            if quantity_to_add <= 0:
                return Response({'error': 'Số lượng phải là một số dương.'}, status=status.HTTP_400_BAD_REQUEST)

            medicine = self.get_object()
            medicine.stock_quantity += quantity_to_add
            medicine.save()

            with transaction.atomic():
                medicine = self.get_object()
                medicine.stock_quantity += quantity_to_add
                medicine.save()

                StockTransaction.objects.create(
                    medicine=medicine,
                    transaction_type=StockTransaction.TransactionType.STOCK_IN,
                    quantity=quantity_to_add, # Ghi số lượng nhập là số dương
                    notes=notes,
                    created_by=get_current_account(request)
                )
            
            # Trả về thông tin thuốc đã được cập nhật
            serializer = self.get_serializer(medicine)
            return Response(serializer.data, status=status.HTTP_200_OK)

        except (ValueError, TypeError):
            return Response({'error': 'Số lượng không hợp lệ.'}, status=status.HTTP_400_BAD_REQUEST)
        
    # <<< THÊM ACTION MỚI CHO VIỆC XUẤT KHO >>>
    @action(detail=True, methods=['post'], permission_classes=[IsAppAdminUser])
    def remove_stock(self, request, pk=None):
        """
        Action cho Admin để trừ (xuất) số lượng khỏi kho.
        Payload: {'quantity': 10, 'notes': 'Thuốc hỏng'}
        """
        try:
            quantity_to_remove = int(request.data.get('quantity', 0))
            notes = request.data.get('notes', 'Xuất kho thủ công')

            if quantity_to_remove <= 0:
                return Response({'error': 'Số lượng phải là một số dương.'}, status=status.HTTP_400_BAD_REQUEST)

            medicine = self.get_object()

            if medicine.stock_quantity < quantity_to_remove:
                return Response({
                    'error': f'Không đủ số lượng để xuất. Tồn kho chỉ còn {medicine.stock_quantity}.'
                }, status=status.HTTP_400_BAD_REQUEST)

            # Bắt đầu transaction
            with transaction.atomic():
                medicine.stock_quantity -= quantity_to_remove
                medicine.save()

                # Ghi lại lịch sử giao dịch
                StockTransaction.objects.create(
                    medicine=medicine,
                    transaction_type=StockTransaction.TransactionType.STOCK_OUT,
                    quantity=-quantity_to_remove, # Ghi số lượng xuất là số âm
                    notes=notes,
                    created_by=get_current_account(request)
                )

            serializer = self.get_serializer(medicine)
            return Response(serializer.data, status=status.HTTP_200_OK)

        except (ValueError, TypeError):
            return Response({'error': 'Số lượng không hợp lệ.'}, status=status.HTTP_400_BAD_REQUEST)
        

# ==========================
# StockTransaction
# ==========================    
class StockTransactionViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet chỉ đọc để xem lịch sử các giao dịch trong kho.
    Chỉ dành cho Admin.
    """
    queryset = StockTransaction.objects.all().order_by('-created_at')
    serializer_class = StockTransactionSerializer
    permission_classes = [IsAppAdminUser] # Chỉ Admin được xem
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['medicine', 'transaction_type'] # Cho phép lọc theo thuốc và loại giao dịch
    search_fields = ['notes', 'medicine__name'] # Cho phép tìm kiếm theo ghi chú

# ==========================
# Admin
# ==========================   
class AdminReportView(APIView):
    permission_classes = [IsAppAdminUser]

    # HÀM GET CHÍNH - HOẠT ĐỘNG NHƯ MỘT BỘ ĐIỀU HƯỚNG
    def get(self, request, report_type, *args, **kwargs):
        if report_type == 'appointments-over-time':
            return self.get_appointments_over_time(request, *args, **kwargs)
        elif report_type == 'appointment-status':
            return self.get_appointment_status_distribution(request, *args, **kwargs)
        elif report_type == 'stock_over_time':
            return self.get_stock_transactions_over_time(request, *args, **kwargs)
        else:
            return Response({'error': 'Loại báo cáo không hợp lệ.'}, status=status.HTTP_404_NOT_FOUND)

    # --- CÁC HÀM HELPER CHO TỪNG LOẠI BÁO CÁO ---

    def get_appointments_over_time(self, request, *args, **kwargs):
        today = timezone.localtime(timezone.now()).date()
        default_start_date = today - timedelta(days=6)
        start_date_str = request.query_params.get('start_date', default_start_date.strftime('%Y-%m-%d'))
        end_date_str = request.query_params.get('end_date', today.strftime('%Y-%m-%d'))
        try:
            start_date = datetime.strptime(start_date_str, '%Y-%m-%d').date()
            end_date = datetime.strptime(end_date_str, '%Y-%m-%d').date()
        except ValueError:
            return Response({'error': 'Định dạng ngày không hợp lệ. Vui lòng dùng YYYY-MM-DD.'}, status=status.HTTP_400_BAD_REQUEST)
        
        appointments_by_day = (
            Appointment.objects
            .filter(appointment_time__date__range=[start_date, end_date])
            .annotate(date=TruncDate('appointment_time'))
            .values('date')
            .annotate(count=Count('id'))
            .order_by('date')
        )
        report_data = [{'date': item['date'].strftime('%Y-%m-%d'), 'count': item['count']} for item in appointments_by_day]
        return Response(report_data, status=status.HTTP_200_OK)

    def get_appointment_status_distribution(self, request, *args, **kwargs):
        status_counts = (
            Appointment.objects
            .values('status')
            .annotate(count=Count('id'))
            .order_by('-count')
        )
        status_display_map = dict(Appointment.Status.choices)
        report_data = [
            {
                'status': item['status'],
                'status_display': status_display_map.get(item['status'], item['status']),
                'count': item['count']
            }
            for item in status_counts
        ]
        return Response(report_data, status=status.HTTP_200_OK)

    def get_stock_transactions_over_time(self, request, *args, **kwargs):
        today = timezone.localtime(timezone.now()).date()
        default_start_date = today - timedelta(days=6)
        start_date_str = request.query_params.get('start_date', default_start_date.strftime('%Y-%m-%d'))
        end_date_str = request.query_params.get('end_date', today.strftime('%Y-%m-%d'))
        
        try:
            start_date = datetime.strptime(start_date_str, '%Y-%m-%d').date()
            end_date = datetime.strptime(end_date_str, '%Y-%m-%d').date()
        except ValueError:
            return Response({'error': 'Invalid date format.'}, status=status.HTTP_400_BAD_REQUEST)

        transactions = StockTransaction.objects.filter(created_at__date__range=[start_date, end_date])
        summary = (
            transactions
            .annotate(date=TruncDate('created_at'))
            .values('date', 'transaction_type')
            .annotate(total_quantity=Sum('quantity'))
            .order_by('date')
        )

        if not list(summary):
            return Response([], status=status.HTTP_200_OK)

        # --- Phần code pandas không thay đổi nhiều, chỉ sửa key ---
        df = pd.DataFrame(list(summary))
        df['date'] = pd.to_datetime(df['date'])
        pivot = df.pivot_table(index='date', columns='transaction_type', values='total_quantity', fill_value=0).reset_index()
        all_dates = pd.date_range(start=start_date, end=end_date, freq='D')
        all_dates_df = pd.DataFrame(all_dates, columns=['date'])
        merged_df = pd.merge(all_dates_df, pivot, on='date', how='left').fillna(0)

        report_data = []
        for _, row in merged_df.iterrows():
            # <<< THAY ĐỔI CHÍNH NẰM Ở CÁCH TÍNH TOÁN DƯỚI ĐÂY >>>
            
            # Tổng nhập kho = Nhập theo phiếu + Điều chỉnh tăng
            stock_in_val = 0
            if 'VOUCHER_IN' in row:
                stock_in_val += int(row['VOUCHER_IN'])
            # Điều chỉnh thủ công là số dương thì tính là nhập
            if 'MANUAL_ADJUST' in row and row['MANUAL_ADJUST'] > 0:
                stock_in_val += int(row['MANUAL_ADJUST'])
            
            # Tổng xuất thủ công = Xuất theo phiếu + Điều chỉnh giảm
            stock_out_manual_val = 0
            if 'VOUCHER_OUT' in row:
                stock_out_manual_val += abs(int(row['VOUCHER_OUT']))
            # Điều chỉnh thủ công là số âm thì tính là xuất
            if 'MANUAL_ADJUST' in row and row['MANUAL_ADJUST'] < 0:
                stock_out_manual_val += abs(int(row['MANUAL_ADJUST']))

            report_data.append({
                'date': row['date'].strftime('%Y-%m-%d'),
                'stock_in': stock_in_val,
                'stock_out_manual': stock_out_manual_val,
                'stock_out_prescription': abs(int(row.get('PRESCRIPTION', 0))),
            })
            
        return Response(report_data, status=status.HTTP_200_OK)
    # def get_stock_over_time(self, request, *args, **kwargs):
    #     """
    #     GET /api/admin/reports/stock-over-time/?start_date=YYYY-MM-DD&end_date=YYYY-MM-DD
    #     (chấp nhận ISO có 'T', ví dụ 2025-11-01T12:00:00)
    #     Trả về: [{date, stock_in, stock_out_manual, stock_out_prescription}, ...]
    #     """
    #     # 1) Parse time range: mặc định 7 ngày gần nhất
    #     today = timezone.localtime(timezone.now()).date()
    #     default_start = today - timedelta(days=6)

    #     raw_start = request.query_params.get('start_date')
    #     raw_end = request.query_params.get('end_date')

    #     # Cho phép client gửi ISO có "T"
    #     if raw_start and 'T' in raw_start:
    #         raw_start = raw_start.split('T')[0]
    #     if raw_end and 'T' in raw_end:
    #         raw_end = raw_end.split('T')[0]

    #     try:
    #         start_date = datetime.strptime(raw_start, '%Y-%m-%d').date() if raw_start else default_start
    #         end_date = datetime.strptime(raw_end, '%Y-%m-%d').date() if raw_end else today
    #     except ValueError:
    #         return Response({'error': 'Định dạng ngày không hợp lệ (YYYY-MM-DD).'}, status=status.HTTP_400_BAD_REQUEST)

    #     # 2) Gom theo ngày, tính 3 cột: nhập kho / xuất tay / xuất qua đơn
    #     qs = (
    #         StockTransaction.objects
    #         .filter(created_at__date__range=[start_date, end_date])
    #         .annotate(d=TruncDate('created_at'))
    #         .values('d')
    #         .annotate(
    #             stock_in=Sum(Case(
    #                 When(transaction_type=StockTransaction.TransactionType.STOCK_IN, then='quantity'),
    #                 default=0, output_field=IntegerField()
    #             )),
    #             stock_out_manual=Sum(Case(
    #                 When(transaction_type=StockTransaction.TransactionType.STOCK_OUT, then='quantity'),
    #                 default=0, output_field=IntegerField()
    #             )),
    #             stock_out_prescription=Sum(Case(
    #                 When(transaction_type=StockTransaction.TransactionType.PRESCRIPTION, then='quantity'),
    #                 default=0, output_field=IntegerField()
    #             )),
    #         )
    #         .order_by('d')
    #     )

    #     # 3) Điền ngày thiếu (0), đổi số âm sang dương cho 2 loại "xuất"
    #     by_day = {row['d']: row for row in qs}
    #     result = []
    #     cur = start_date
    #     while cur <= end_date:
    #         row = by_day.get(cur)
    #         if row:
    #             stock_in = row['stock_in'] or 0
    #             out_manual = abs(row['stock_out_manual'] or 0)
    #             out_rx = abs(row['stock_out_prescription'] or 0)
    #         else:
    #             stock_in = out_manual = out_rx = 0

    #         result.append({
    #             'date': cur.strftime('%Y-%m-%d'),
    #             'stock_in': stock_in,
    #             'stock_out_manual': out_manual,
    #             'stock_out_prescription': out_rx,
    #         })
    #         cur += timedelta(days=1)

    #     return Response(result, status=status.HTTP_200_OK)



class GlobalSearchView(APIView):
    """
    API View cho chức năng tìm kiếm tổng hợp (Bác sĩ, Dịch vụ, Chuyên khoa).
    Bất kỳ ai đã đăng nhập đều có thể sử dụng.
    """
    permission_classes = [drf_perms.IsAuthenticated]

    def get(self, request, *args, **kwargs):
        query = request.query_params.get('q', '') # Lấy query từ tham số `q`

        # Nếu query rỗng, trả về kết quả rỗng
        if not query:
            return Response({
                'doctors': [],
                'services': [],
                'specialties': [],
            })

        # Tìm kiếm Bác sĩ
        doctors_qs = UserAccount.objects.filter(
            role=UserAccount.Role.DOCTOR,
            is_active=True,
            # Tìm kiếm trên nhiều trường
            first_name__icontains=query
        ) | UserAccount.objects.filter(
            role=UserAccount.Role.DOCTOR,
            is_active=True,
            last_name__icontains=query
        )
        doctors_qs = doctors_qs.distinct()[:5] # Giới hạn 5 kết quả

        # Tìm kiếm Dịch vụ
        services_qs = Service.objects.filter(name__icontains=query)[:5]

        # Tìm kiếm Chuyên khoa
        specialties_qs = Specialty.objects.filter(name__icontains=query)[:5]

        # Serialize kết quả
        doctors_data = UserAccountSummarySerializer(doctors_qs, many=True, context={'request': request}).data
        services_data = ServiceSerializer(services_qs, many=True).data
        specialties_data = SpecialtySerializer(specialties_qs, many=True).data
        
        # Đóng gói và trả về
        return Response({
            'doctors': doctors_data,
            'services': services_data,
            'specialties': specialties_data,
        })

class StockVoucherViewSet(viewsets.ModelViewSet):
    """
    ViewSet để quản lý Phiếu Nhập/Xuất kho.
    Chỉ Admin có thể tạo và xem.
    """
    queryset = StockVoucher.objects.all()
    serializer_class = StockVoucherSerializer
    permission_classes = [IsAppAdminUser]

    def perform_create(self, serializer):
        # Tự động gán người tạo là user đang đăng nhập
        serializer.save(created_by=get_current_account(self.request))