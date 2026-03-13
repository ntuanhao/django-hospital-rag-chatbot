# api/permissions.py
from rest_framework import permissions
from .models import UserAccount

# ---- Helpers ---------------------------------------------------------------

def resolve_useraccount(user) -> UserAccount | None:
    """
    Trả về UserAccount tương ứng với request.user (nếu có).
    - Nếu request.user chính là UserAccount -> trả luôn
    - Nếu request.user là Django User -> lấy qua OneToOne: user.useraccount
    """
    if user is None or not getattr(user, "is_authenticated", False):
        return None

    if isinstance(user, UserAccount):
        return user

    return getattr(user, "useraccount", None)


def resolve_role(user) -> str | None:
    ua = resolve_useraccount(user)
    return getattr(ua, "role", None)

#  2 HÀM HELPER VÀO ĐÂY 
def get_current_account(request):
    username = getattr(request.user, "username", None)
    if not username:
        return None
    return UserAccount.objects.filter(username=username, is_active=True).first()

def get_current_role(request):
    acc = get_current_account(request)
    return acc.role if acc else None

# ---- Global permissions theo vai trò --------------------------------------

class IsAppAdminUser(permissions.BasePermission):
    """Admin: chấp nhận Django superuser HOẶC UserAccount.role = ADMIN"""
    def has_permission(self, request, view):
        if getattr(request.user, "is_superuser", False):
            return True
        return resolve_role(request.user) == UserAccount.Role.ADMIN


class IsDoctorUser(permissions.BasePermission):
    def has_permission(self, request, view):
        return resolve_role(request.user) == UserAccount.Role.DOCTOR


class IsReceptionistUser(permissions.BasePermission):
    def has_permission(self, request, view):
        return resolve_role(request.user) == UserAccount.Role.RECEPTIONIST


class IsPatientUser(permissions.BasePermission):
    def has_permission(self, request, view):
        return resolve_role(request.user) == UserAccount.Role.PATIENT





class IsAdminOrReceptionist(permissions.BasePermission):
    def has_permission(self, request, view):
        role = resolve_role(request.user)
        return role in (UserAccount.Role.ADMIN, UserAccount.Role.RECEPTIONIST)


# ---- Object-level (nếu bạn dùng) ------------------------------------------

class IsOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        ua = resolve_useraccount(request.user)
        if ua is None:
            return False

        if hasattr(obj, "user"):
            obj_user = getattr(obj, "user")
            obj_ua = obj_user if isinstance(obj_user, UserAccount) else getattr(obj_user, "useraccount", None)
            if obj_ua is not None:
                return obj_ua == ua

        if hasattr(obj, "patient"):
            return obj.patient == ua

        return False


class IsDoctorAssociated(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        ua = resolve_useraccount(request.user)
        if ua is None:
            return False

        if hasattr(obj, "doctor"):
            return obj.doctor == ua

        if hasattr(obj, "appointment") and hasattr(obj.appointment, "doctor"):
            return obj.appointment.doctor == ua

        return False

class IsDoctorOrIsAppAdminUser(permissions.BasePermission):
    """
    Cho phép truy cập nếu người dùng là Bác sĩ HOẶC Admin.
    """
    def has_permission(self, request, view):
        user = get_current_account(request)
        return user is not None and (user.role == UserAccount.Role.DOCTOR or user.role == UserAccount.Role.ADMIN)