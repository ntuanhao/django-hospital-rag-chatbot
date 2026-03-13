// lib/screens/admin/admin_user_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/providers/user_provider.dart';
import 'package:go_router/go_router.dart';


class AdminUserDetailScreen extends ConsumerStatefulWidget {
  final int userId;
  const AdminUserDetailScreen({required this.userId, super.key});

  @override
  ConsumerState<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends ConsumerState<AdminUserDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // <<< THAY ĐỔI QUAN TRỌNG: GỌI FETCH TRONG INITSTATE >>>
  @override
  void initState() {
    super.initState();
    // Gọi hàm fetch ngay khi widget được tạo lần đầu tiên
    // `addPostFrameCallback` để đảm bảo `ref` có thể được đọc một cách an toàn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminUserDetailProvider.notifier).fetch(widget.userId);
    });
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final dataToUpdate = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'phone_number': _phoneController.text,
      };

      await ref.read(adminUserDetailProvider.notifier).updateUser(dataToUpdate);
      
      final state = ref.read(adminUserDetailProvider);
      if (mounted) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${state.error}'), backgroundColor: Colors.red),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe provider để lấy dữ liệu và trạng thái
    final userState = ref.watch(adminUserDetailProvider);
    final isUpdating = userState is AsyncLoading && userState.hasValue; // Đang cập nhật

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Người dùng'),
      ),
      body: userState.when(
        // Trạng thái ban đầu sẽ là loading (do Completer trong build)
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Đã xảy ra lỗi: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(adminUserDetailProvider.notifier).fetch(widget.userId), 
                child: const Text('Thử lại'),
              )
            ],
          ),
        ),
        data: (user) {
          // Điền dữ liệu vào controller khi có data
          _firstNameController.text = user.firstName;
          _lastNameController.text = user.lastName;
          _emailController.text = user.email ;
          _phoneController.text = user.phoneNumber ?? '';
          
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
                    child: user.avatar == null ? const Icon(Icons.person, size: 40) : null,
                  ),
                ),
                const SizedBox(height: 16),
                Center(child: Text(user.username, style: Theme.of(context).textTheme.headlineSmall)),
                Center(child: Chip(label: Text(user.role))),
                const Divider(height: 32),

                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Tên'),
                  validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Họ'),
                  validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isUpdating ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isUpdating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Lưu thay đổi'),
                ),
                const SizedBox(height: 24),
                // Chỉ hiển thị nút này nếu người dùng là Bác sĩ
                if (user.role == 'DOCTOR')
                  OutlinedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: const Text('Quản lý Lịch làm việc'),
                    onPressed: () {
                      // Điều hướng đến màn hình quản lý lịch và truyền đối tượng `user`
                      context.push('/admin/dashboard/users/${user.id}/schedule', extra: user);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  if (user.role == 'PATIENT')
                  OutlinedButton.icon(
                    icon: const Icon(Icons.folder_copy_outlined),
                    label: const Text('Xem Lịch sử Khám bệnh'),
                    onPressed: () {
                      // Điều hướng đến màn hình lịch sử khám bệnh
                      context.push('/admin/dashboard/users/${user.id}/medical-history', extra: user);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}