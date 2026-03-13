// lib/models/user_account.dart

// -----------------------------------------------------------------
// LỚP HỒ SƠ BÁC SĨ (DOCTOR PROFILE)
// -----------------------------------------------------------------
class DoctorProfile {
  final String specialtyName;
  final String licenseNumber;
  final String? bio;

  DoctorProfile({
    required this.specialtyName,
    required this.licenseNumber,
    this.bio,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      specialtyName: json['specialty_name'] as String,
      licenseNumber: json['license_number'] as String,
      bio: json['bio'] as String?,
    );
  }
}

// -----------------------------------------------------------------
// LỚP HỒ SƠ BỆNH NHÂN (PATIENT PROFILE)
// -----------------------------------------------------------------
class PatientProfile {
  final String? medicalHistory;
  final String? allergies;

  PatientProfile({
    this.medicalHistory,
    this.allergies,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      medicalHistory: json['medical_history'] as String?,
      allergies: json['allergies'] as String?,
    );
  }
}

// -----------------------------------------------------------------
// LỚP HỒ SƠ LỄ TÂN (RECEPTIONIST PROFILE)
// -----------------------------------------------------------------
class ReceptionistProfile {
  final String employeeId;
  final DateTime startDate;

  ReceptionistProfile({
    required this.employeeId,
    required this.startDate,
  });

  factory ReceptionistProfile.fromJson(Map<String, dynamic> json) {
    return ReceptionistProfile(
      employeeId: json['employee_id'] as String,
      // API trả về ngày dưới dạng chuỗi "YYYY-MM-DD", cần chuyển đổi sang DateTime
      startDate: DateTime.parse(json['start_date'] as String),
    );
  }
}


// -----------------------------------------------------------------
// LỚP TÀI KHOẢN NGƯỜI DÙNG CHÍNH (USER ACCOUNT)
// -----------------------------------------------------------------
class UserAccount {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? phoneNumber;
  final String? avatar;
  final DateTime? dateOfBirth;
  final String? address;
  final String? gender;
  
  // profile có thể là DoctorProfile, PatientProfile, ReceptionistProfile, hoặc null
  final dynamic profile;

  UserAccount({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.avatar,
    this.dateOfBirth,
    this.address,
    this.gender,
    this.profile,
  });

  String get fullName => '$lastName $firstName'.trim();

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    // Xử lý logic để tạo đối tượng profile tương ứng với vai trò
    dynamic profileObject;
    if (json['profile'] != null) {
      switch (json['role']) {
        case 'DOCTOR':
          profileObject = DoctorProfile.fromJson(json['profile']);
          break;
        case 'PATIENT':
          profileObject = PatientProfile.fromJson(json['profile']);
          break;
        case 'RECEPTIONIST':
          profileObject = ReceptionistProfile.fromJson(json['profile']);
          break;
      }
    }

    return UserAccount(
      id: json['id'] as int,
      username: json['username'] as String,
      firstName: json['first_name'] as String, // Chú ý key JSON từ backend
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      phoneNumber: json['phone_number'] as String?,
      avatar: json['avatar'] as String?,
      // API trả về ngày sinh dưới dạng chuỗi, cần chuyển đổi và kiểm tra null
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      address: json['address'] as String?,
      gender: json['gender'] as String?,
      profile: profileObject,
    );
  }
}

// -----------------------------------------------------------------
// LỚP DỮ LIỆU TRẢ VỀ KHI ĐĂNG NHẬP
// -----------------------------------------------------------------
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final int userId;
  final String role;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access'] as String,
      refreshToken: json['refresh'] as String,
      userId: json['user_id'] as int,
      role: json['role'] as String,
    );
  }
}