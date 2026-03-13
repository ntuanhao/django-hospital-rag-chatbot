# api/validators.py
from django.core.exceptions import ValidationError
from django.utils import timezone

def validate_no_future_date(value):
    """
    Validator để đảm bảo ngày được chọn không nằm trong tương lai.
    """
    if value > timezone.now().date():
        raise ValidationError("Ngày sinh không được nằm trong tương lai.")