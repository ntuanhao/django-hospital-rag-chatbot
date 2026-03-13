
// lib/screens/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserAccount user;
  const EditProfileScreen({required this.user, Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers cho các trường chung
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _dateController;
  File? _selectedAvatar;
  // State cho các trường không phải text
  DateTime? _selectedDate;
  String? _selectedGender;
  final List<String> _genderOptions = ['Nam', 'Nữ', 'Khác'];
  final Map<String, String> _genderApiMap = {'Nam': 'MALE', 'Nữ': 'FEMALE', 'Khác': 'OTHER'};
  final Map<String, String> _genderDisplayMap = {'MALE': 'Nam', 'FEMALE': 'Nữ', 'OTHER': 'Khác'};

  
  // Controllers cho các trường profile
  late final TextEditingController _medicalHistoryController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _bioController;
  late final TextEditingController _licenseController;

  @override
  void initState() {
    super.initState();
    final user = widget.user;

    _firstNameController = TextEditingController(text: user.firstName);
    _lastNameController = TextEditingController(text: user.lastName);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phoneNumber);
    _addressController = TextEditingController(text: user.address);
    _dateController = TextEditingController();

    if (user.dateOfBirth != null) {
      _selectedDate = user.dateOfBirth;
      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    }
    if (user.gender != null && _genderDisplayMap.containsKey(user.gender)) {
      _selectedGender = _genderDisplayMap[user.gender!];
    }

    _medicalHistoryController = TextEditingController();
    _allergiesController = TextEditingController();
    _bioController = TextEditingController();
    _licenseController = TextEditingController();

    if (user.role == 'PATIENT' && user.profile is PatientProfile) {
      final profile = user.profile as PatientProfile;
      _medicalHistoryController.text = profile.medicalHistory ?? '';
      _allergiesController.text = profile.allergies ?? '';
    } else if (user.role == 'DOCTOR' && user.profile is DoctorProfile) {
      final profile = user.profile as DoctorProfile;
      _bioController.text = profile.bio ?? '';
      _licenseController.text = profile.licenseNumber;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    _bioController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedAvatar = File(pickedFile.path);
      });
    }
  }


  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final Map<String, dynamic> payload = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone_number': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'date_of_birth': _selectedDate?.toIso8601String().split('T').first,
      'gender': _selectedGender != null ? _genderApiMap[_selectedGender] : null,
    };
    
    final Map<String, dynamic> profilePayload = {};
    if (widget.user.role == 'PATIENT') {
      // profilePayload['medical_history'] = _medicalHistoryController.text.trim();
      profilePayload['allergies'] = _allergiesController.text.trim();
    } else if (widget.user.role == 'DOCTOR') {
      profilePayload['bio'] = _bioController.text.trim();
      // profilePayload['license_number'] = _licenseController.text.trim();
    }
    
    if (profilePayload.isNotEmpty) {
      payload['profile'] = profilePayload;
    }
    

    // final success = await ref.read(userProfileProvider.notifier).updateProfile(payload);
    // setState(() => _isLoading = false);
    final success = await ref.read(userProfileProvider.notifier).updateProfile(
      payload,
      avatarPath: _selectedAvatar?.path, // Truyền đường dẫn ảnh
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Cập nhật hồ sơ thành công!' : 'Cập nhật thất bại, vui lòng thử lại.'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa Hồ sơ'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Lưu thay đổi',
              onPressed: _submitUpdate,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    // Hiển thị ảnh mới chọn hoặc ảnh cũ
                    backgroundImage: _selectedAvatar != null
                        ? FileImage(_selectedAvatar!)
                        : (widget.user.avatar != null
                            ? NetworkImage(widget.user.avatar!)
                            : null) as ImageProvider?,
                    child: _selectedAvatar == null && widget.user.avatar == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            
            Text('Thông tin cơ bản', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(controller: _lastNameController, decoration: inputDecoration.copyWith(labelText: 'Họ')),
            const SizedBox(height: 16),
            TextFormField(controller: _firstNameController, decoration: inputDecoration.copyWith(labelText: 'Tên')),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: inputDecoration.copyWith(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!emailRegex.hasMatch(v)) return 'Email không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(controller: _phoneController, decoration: inputDecoration.copyWith(labelText: 'Số điện thoại'), keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            TextFormField(controller: _addressController, decoration: inputDecoration.copyWith(labelText: 'Địa chỉ')),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              decoration: inputDecoration.copyWith(labelText: 'Ngày sinh', suffixIcon: const Icon(Icons.calendar_today)),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: inputDecoration.copyWith(labelText: 'Giới tính'),
              items: _genderOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
              onChanged: (newValue) => setState(() => _selectedGender = newValue),
            ),
            
            const Divider(height: 40),

            _buildRoleSpecificFields(context, inputDecoration),
          ],
        ),
      ),
    );
  }

  // Widget _buildRoleSpecificFields(BuildContext context, InputDecoration decoration) {
  //   switch (widget.user.role) {
  //     case 'PATIENT':
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('Thông tin Y tế', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
  //           const SizedBox(height: 16),
  //           TextFormField(controller: _medicalHistoryController, decoration: decoration.copyWith(labelText: 'Tiền sử bệnh án'), maxLines: 3),
  //           const SizedBox(height: 16),
  //           TextFormField(controller: _allergiesController, decoration: decoration.copyWith(labelText: 'Dị ứng'), maxLines: 3),
  //         ],
  //       );
  //     case 'DOCTOR':
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('Thông tin Chuyên môn', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
  //           const SizedBox(height: 16),
  //           TextFormField(controller: _licenseController, decoration: decoration.copyWith(labelText: 'Số giấy phép')),
  //           const SizedBox(height: 16),
  //           TextFormField(controller: _bioController, decoration: decoration.copyWith(labelText: 'Giới thiệu'), maxLines: 5),
  //         ],
  //       );
  Widget _buildRoleSpecificFields(BuildContext context, InputDecoration decoration) {
    switch (widget.user.role) {
      case 'PATIENT':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thông tin Y tế', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Hiển thị Tiền sử bệnh án nhưng không cho sửa
            ListTile(
              leading: const Icon(Icons.history_edu),
              title: const Text('Tiền sử bệnh án (chỉ xem)'),
              subtitle: Text((widget.user.profile as PatientProfile?)?.medicalHistory ?? 'Chưa có'),
            ),
            const SizedBox(height: 16),
            // Cho phép sửa Dị ứng
            TextFormField(controller: _allergiesController, decoration: decoration.copyWith(labelText: 'Dị ứng'), maxLines: 3),
          ],
        );
      case 'DOCTOR':
        final profile = widget.user.profile as DoctorProfile?;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thông tin Chuyên môn', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Hiển thị Chuyên khoa và Số giấy phép nhưng không cho sửa
            ListTile(
              leading: const Icon(Icons.medical_services_outlined),
              title: const Text('Chuyên khoa (không đủ quyền để thay đổi)'),
              subtitle: Text(profile?.specialtyName ?? 'N/A'),
            ),
             ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Số giấy phép (không đủ quyền để thay đổi)'),
              subtitle: Text(profile?.licenseNumber ?? 'N/A'),
            ),
            const SizedBox(height: 16),
            // Cho phép sửa Giới thiệu
            TextFormField(controller: _bioController, decoration: decoration.copyWith(labelText: 'Giới thiệu'), maxLines: 5),
          ],
        );
      case 'RECEPTIONIST':
         return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thông tin Nhân viên', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text('Mã nhân viên (Không thể thay đổi)'),
              subtitle: Text((widget.user.profile as ReceptionistProfile?)?.employeeId ?? 'N/A'),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}