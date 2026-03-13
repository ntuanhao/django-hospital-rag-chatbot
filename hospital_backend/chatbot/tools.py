# chatbot/tools.py
from django.utils import timezone
from api.models import Service, Appointment, UserAccount, Specialty
import datetime

def get_service_info_tool(keyword):
    """Tìm kiếm dịch vụ và giá tiền"""
    services = Service.objects.filter(name__icontains=keyword)[:5]
    if not services:
        return "Không tìm thấy dịch vụ nào khớp với yêu cầu."
    
    result = []
    for s in services:
        result.append(f"- {s.name}: {s.price:,.0f} VNĐ")
    return "\n".join(result)

def get_available_slots_tool(specialty_name=None, date_str=None):
    """
    Kiểm tra lịch trống. 
    Lưu ý: Logic này đơn giản hóa để AI tham khảo. 
    Thực tế AI sẽ trả về JSON để Frontend gọi API `available-slots` chuẩn xác hơn.
    """
    if not date_str:
        date_str = timezone.now().strftime('%Y-%m-%d')
    
    try:
        target_date = datetime.datetime.strptime(date_str, '%Y-%m-%d').date()
    except ValueError:
        return "Định dạng ngày không hợp lệ (cần YYYY-MM-DD)."

    # Tìm bác sĩ theo chuyên khoa
    doctors = UserAccount.objects.filter(role=UserAccount.Role.DOCTOR)
    if specialty_name:
        doctors = doctors.filter(doctor_profile__specialty__name__icontains=specialty_name)
    
    if not doctors.exists():
        return f"Không tìm thấy bác sĩ nào thuộc khoa {specialty_name}."

    # Giả lập trả về thông tin tổng quan
    return f"Hiện có {doctors.count()} bác sĩ trực vào ngày {date_str}. Vui lòng dùng tính năng Đặt lịch để xem giờ chi tiết."