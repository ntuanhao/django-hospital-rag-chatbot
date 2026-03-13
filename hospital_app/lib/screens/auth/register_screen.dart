// // lib/screens/auth/register_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:hospital_app/providers/auth_provider.dart';
// import 'package:hospital_app/providers/auth_state.dart';
// import 'package:intl/intl.dart';

// class RegisterScreen extends ConsumerStatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends ConsumerState<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
  
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _firstNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _dateController = TextEditingController();
//   final _addressController = TextEditingController();
  
//   DateTime? _selectedDate;
//   String? _selectedGender;
//   final List<String> _genderOptions = ['Nam', 'Nữ', 'Khác'];
//   final Map<String, String> _genderApiMap = {'Nam': 'MALE', 'Nữ': 'FEMALE', 'Khác': 'OTHER'};

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _lastNameController.dispose();
//     _firstNameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _dateController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(1900),
//       // <<< THAY ĐỔI DUY NHẤT NẰM Ở ĐÂY >>>
//       // lastDate sẽ là ngày hôm nay, không cho phép chọn ngày mai
//       lastDate: DateTime.now(), 
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//         _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
//       });
//     }
// }

//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Text('Thành công!'),
//           content: const Text('Tài khoản của bạn đã được tạo. Vui lòng đăng nhập để tiếp tục.'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('OK'),
//               onPressed: () {
//                 // Sử dụng GoRouter để điều hướng về trang login
//                 // `go` sẽ thay thế toàn bộ stack điều hướng, phù hợp cho trường hợp này
//                 context.go('/login');
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _submitRegister() async {
//     if (!_formKey.currentState!.validate()) return;
    
//     final success = await ref.read(authProvider.notifier).register(
//       username: _usernameController.text.trim(),
//       password: _passwordController.text.trim(),
//       firstName: _firstNameController.text.trim(),
//       lastName: _lastNameController.text.trim(),
//       email: _emailController.text.trim(),
//       phoneNumber: _phoneController.text.trim(),
//       address: _addressController.text.trim(),
//       gender: _selectedGender != null ? _genderApiMap[_selectedGender] : null,
//       dateOfBirth: _selectedDate,
//     );

//     if (success) {
//       _showSuccessDialog();
//     }
//     // Nếu thất bại, ref.listen sẽ tự động hiển thị SnackBar lỗi
//   }

//   @override
//   Widget build(BuildContext context) {
//     final primaryGreen = Colors.green.shade700;
    
//     ref.listen<AuthState>(authProvider, (previous, next) {
//       if (next.status == AuthStatus.unauthenticated && next.errorMessage != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(next.errorMessage!),
//             backgroundColor: Colors.red.shade600,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     });

//     final isLoading = ref.watch(authProvider).status == AuthStatus.loading;
//     final inputDecoration = InputDecoration(
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//     );

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Tạo tài khoản'),
//         centerTitle: true,
//         backgroundColor: primaryGreen,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.green.shade50, Colors.white],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 480),
//               child: Card(
//                 elevation: 6,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Text('Thông tin đăng nhập', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 16),
//                         TextFormField(controller: _usernameController, decoration: inputDecoration.copyWith(labelText: 'Tên đăng nhập*'), validator: (v) => v!.isEmpty ? 'Vui lòng nhập' : null),
//                         const SizedBox(height: 16),
//                         TextFormField(controller: _passwordController, decoration: inputDecoration.copyWith(labelText: 'Mật khẩu*'), obscureText: true, validator: (v) => v!.length < 6 ? 'Mật khẩu phải > 5 ký tự' : null),
//                         const SizedBox(height: 16),
//                         TextFormField(controller: _confirmPasswordController, decoration: inputDecoration.copyWith(labelText: 'Xác nhận mật khẩu*'), obscureText: true, validator: (v) => v != _passwordController.text ? 'Mật khẩu không khớp' : null),
//                         const Divider(height: 40),
//                         Text('Thông tin cá nhân', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 16),
//                         TextFormField(controller: _lastNameController, decoration: inputDecoration.copyWith(labelText: 'Họ*'), validator: (v) => v!.isEmpty ? 'Vui lòng nhập' : null),
//                         const SizedBox(height: 16),
//                         TextFormField(controller: _firstNameController, decoration: inputDecoration.copyWith(labelText: 'Tên*'), validator: (v) => v!.isEmpty ? 'Vui lòng nhập' : null),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _emailController,
//                           decoration: inputDecoration.copyWith(labelText: 'Email*'),
//                           keyboardType: TextInputType.emailAddress,
//                           validator: (v) {
//                             if (v == null || v.isEmpty) return 'Vui lòng nhập email';
//                             final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//                             if (!emailRegex.hasMatch(v)) return 'Email không hợp lệ';
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(controller: _phoneController, decoration: inputDecoration.copyWith(labelText: 'Số điện thoại'), keyboardType: TextInputType.phone),
//                         const SizedBox(height: 16),
//                         TextFormField(controller: _dateController, decoration: inputDecoration.copyWith(labelText: 'Ngày sinh', suffixIcon: Icon(Icons.calendar_today)), readOnly: true, onTap: () => _selectDate(context)),
//                         const SizedBox(height: 16),
//                         TextFormField(controller: _addressController, decoration: inputDecoration.copyWith(labelText: 'Địa chỉ')),
//                         const SizedBox(height: 16),
//                         DropdownButtonFormField<String>(initialValue: _selectedGender, decoration: inputDecoration.copyWith(labelText: 'Giới tính'), items: _genderOptions.map((String v) => DropdownMenuItem<String>(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => _selectedGender = v)),
//                         const SizedBox(height: 32),
//                         SizedBox(
//                           height: 48,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
//                             onPressed: isLoading ? null : _submitRegister,
//                             child: isLoading ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('TẠO TÀI KHOẢN'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/providers/auth_provider.dart';
import 'package:hospital_app/providers/auth_state.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();
  final _addressController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  final List<String> _genderOptions = ['Nam', 'Nữ', 'Khác'];
  final Map<String, String> _genderApiMap = {
    'Nam': 'MALE',
    'Nữ': 'FEMALE',
    'Khác': 'OTHER'
  };

  static const Color kPrimary = Color(0xFF0BA5A4); // xanh ngọc
  static const Color kAccent = Color(0xFF22C55E);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    _addressController.dispose();
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Thành công!'),
          content: const Text(
              'Tài khoản của bạn đã được tạo. Vui lòng đăng nhập để tiếp tục.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => context.go('/login'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          gender:
              _selectedGender != null ? _genderApiMap[_selectedGender] : null,
          dateOfBirth: _selectedDate,
        );

    if (success) {
      _showSuccessDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated &&
          next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(12),
          ),
        );
      }
    });

    final isLoading = ref.watch(authProvider).status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // card width co giãn theo màn hình, không dùng Expanded/Row để tránh lỗi layout
                final double cardWidth = constraints.maxWidth < 380
                    ? constraints.maxWidth
                    : (constraints.maxWidth * 0.95)
                        .clamp(320.0, 820.0)
                        .toDouble();

                return Center(
                  child: SizedBox(
                    width: cardWidth,
                    child: Card(
                      elevation: 10,
                      shadowColor: Colors.black.withOpacity(.08),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(22, 22, 22, 22),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header
                              Row(
                                children: const [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Color(0xFFE6F6F6),
                                    child: Icon(Icons.local_hospital_rounded,
                                        color: kPrimary, size: 22),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Hospital App',
                                    style: TextStyle(
                                      color: kPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: .2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              
                              const SizedBox(height: 16),

                              const _SectionTitle(
                                  icon: Icons.account_circle_outlined,
                                  title: 'Thông tin đăng nhập'),
                              const SizedBox(height: 12),

                              _TextField(
                                controller: _usernameController,
                                label: 'Tên đăng nhập*',
                                icon: Icons.person_outline,
                                validator: (v) =>
                                    (v == null || v.isEmpty)
                                        ? 'Vui lòng nhập'
                                        : null,
                              ),
                              const SizedBox(height: 12),

                              _TextField(
                                controller: _emailController,
                                label: 'Email*',
                                icon: Icons.alternate_email,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Vui lòng nhập email';
                                  }
                                  final emailRegex =
                                      RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                  if (!emailRegex.hasMatch(v)) {
                                    return 'Email không hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              _TextField(
                                controller: _passwordController,
                                label: 'Mật khẩu*',
                                icon: Icons.lock_outline,
                                obscureText: true,
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Mật khẩu phải > 5 ký tự'
                                    : null,
                              ),
                              const SizedBox(height: 12),

                              _TextField(
                                controller: _confirmPasswordController,
                                label: 'Xác nhận mật khẩu*',
                                icon: Icons.lock_reset,
                                obscureText: true,
                                validator: (v) => (v != _passwordController.text)
                                    ? 'Mật khẩu không khớp'
                                    : null,
                              ),
                              const Divider(height: 32),

                              const _SectionTitle(
                                  icon: Icons.badge_outlined,
                                  title: 'Thông tin cá nhân'),
                              const SizedBox(height: 12),

                              _TextField(
                                controller: _lastNameController,
                                label: 'Họ*',
                                icon: Icons.person_2_outlined,
                                validator: (v) =>
                                    (v == null || v.isEmpty)
                                        ? 'Vui lòng nhập'
                                        : null,
                              ),
                              const SizedBox(height: 12),

                              _TextField(
                                controller: _firstNameController,
                                label: 'Tên*',
                                icon: Icons.person_outline_rounded,
                                validator: (v) =>
                                    (v == null || v.isEmpty)
                                        ? 'Vui lòng nhập'
                                        : null,
                              ),
                              const SizedBox(height: 12),

                              _TextField(
                                controller: _phoneController,
                                label: 'Số điện thoại',
                                icon: Icons.call_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 12),

                              _TextField(
                                controller: _dateController,
                                label: 'Ngày sinh',
                                icon: Icons.cake_outlined,
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                suffix: const Icon(Icons.calendar_today),
                              ),
                              const SizedBox(height: 12),

                              _TextField(
                                controller: _addressController,
                                label: 'Địa chỉ',
                                icon: Icons.location_on_outlined,
                              ),
                              const SizedBox(height: 12),

                              _DropdownField(
                                value: _selectedGender,
                                label: 'Giới tính',
                                icon: Icons.wc_outlined,
                                items: _genderOptions,
                                onChanged: (v) =>
                                    setState(() => _selectedGender = v),
                              ),
                              const SizedBox(height: 22),

                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: isLoading ? null : _submitRegister,
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                        'TẠO TÀI KHOẢN',
                                        style: TextStyle(
                                          letterSpacing: .6,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton.icon(
                                onPressed: () => context.go('/login'),
                                icon: const Icon(Icons.login_rounded),
                                label:
                                    const Text('Đã có tài khoản? Đăng nhập'),
                                style: TextButton.styleFrom(
                                  foregroundColor: kPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ====== Reusable widgets ======
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: _RegisterScreenState.kPrimary.withOpacity(.12),
          child: Icon(icon, size: 16, color: _RegisterScreenState.kPrimary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final Widget? suffix;
  final VoidCallback? onTap;

  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.suffix,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _RegisterScreenState.kPrimary),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF4F9F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: _RegisterScreenState.kPrimary.withOpacity(.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: _RegisterScreenState.kPrimary, width: 1.3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final String label;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.label,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _RegisterScreenState.kPrimary),
        filled: true,
        fillColor: const Color(0xFFF4F9F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: _RegisterScreenState.kPrimary.withOpacity(.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: _RegisterScreenState.kPrimary, width: 1.3),
        ),
      ),
      items: items
          .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _FormStepBadge extends StatelessWidget {
  final int index;
  final String label;
  const _FormStepBadge({required this.index, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _RegisterScreenState.kPrimary.withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: _RegisterScreenState.kPrimary.withOpacity(.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: _RegisterScreenState.kPrimary.withOpacity(.18),
          child: Text(
            '$index',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _RegisterScreenState.kPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ]),
    );
  }
}
