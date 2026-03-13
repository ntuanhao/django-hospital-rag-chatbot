// lib/screens/admin/admin_create_user_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/providers/user_provider.dart';

class AdminCreateUserScreen extends ConsumerStatefulWidget {
  const AdminCreateUserScreen({super.key});

  @override
  ConsumerState<AdminCreateUserScreen> createState() => _AdminCreateUserScreenState();
}

class _AdminCreateUserScreenState extends ConsumerState<AdminCreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedRole; // Vai trò được chọn

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      // Gọi đến Notifier để thực hiện hành động tạo user
      await ref.read(adminCreateUserProvider.notifier).createUser(
            username: _usernameController.text,
            password: _passwordController.text,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            role: _selectedRole!,
            phoneNumber: _phoneController.text,
          );
      
      // Sau khi gọi, kiểm tra xem có lỗi không
      final state = ref.read(adminCreateUserProvider);
      if (state is AsyncError) {
        // Nếu có lỗi, hiển thị SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
         // Nếu thành công, hiển thị SnackBar và quay lại
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo người dùng thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe trạng thái loading từ provider
    final createUserState = ref.watch(adminCreateUserProvider);
    final isLoading = createUserState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Người dùng Mới'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Tên đăng nhập (*)'),
              validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mật khẩu (*)'),
              obscureText: true,
              validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'Tên (*)'),
               validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Họ (*)'),
               validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email (*)'),
              keyboardType: TextInputType.emailAddress,
               validator: (value) {
                if (value!.isEmpty) return 'Không được để trống';
                if (!value.contains('@')) return 'Email không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(labelText: 'Vai trò (*)'),
              items: const [
                DropdownMenuItem(value: 'DOCTOR', child: Text('Bác sĩ')),
                DropdownMenuItem(value: 'RECEPTIONIST', child: Text('Lễ tân')),
                DropdownMenuItem(value: 'PATIENT', child: Text('Bệnh nhân')),
                DropdownMenuItem(value: 'ADMIN', child: Text('Quản trị viên')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
              },
              validator: (value) => value == null ? 'Vui lòng chọn vai trò' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Tạo Người dùng'),
            ),
          ],
        ),
      ),
    );
  }
}