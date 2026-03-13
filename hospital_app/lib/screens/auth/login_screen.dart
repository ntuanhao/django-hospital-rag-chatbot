
// // lib/screens/auth/login_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart'; // <<< ĐÃ THÊM IMPORT
// import 'package:hospital_app/providers/auth_provider.dart';
// import 'package:hospital_app/providers/auth_state.dart';

// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isPasswordVisible = false;

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _submitLogin() {
//     if (!_formKey.currentState!.validate()) return;
//     ref.read(authProvider.notifier).login(
//       _usernameController.text.trim(),
//       _passwordController.text.trim(),
//     );
//   }

//   // <<< THAY ĐỔI DUY NHẤT NẰM Ở HÀM NÀY >>>
//   void _navigateToRegister() {
//     //
//     context.push('/register');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final primaryGreen = Colors.green.shade700;
//     final accentRed = Colors.red.shade600;

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

//     final authState = ref.watch(authProvider);
//     final isLoading = authState.status == AuthStatus.loading;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Đăng nhập'),
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
//                 color: Colors.white,
//                 elevation: 6,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//                   child: Form(
//                     key: _formKey,
//                     // --- PHẦN UI CÒN LẠI GIỮ NGUYÊN ---
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 26,
//                               backgroundColor: primaryGreen.withOpacity(0.15),
//                               child: Icon(Icons.local_hospital, color: accentRed, size: 28),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Chào mừng',
//                                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                           color: primaryGreen,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                   ),
//                                   const SizedBox(height: 2),
//                                   Text(
//                                     '',
//                                     style: Theme.of(context).textTheme.bodyMedium,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 24),
//                         TextFormField(
//                           controller: _usernameController,
//                           textInputAction: TextInputAction.next,
//                           decoration: InputDecoration(
//                             labelText: 'Tên đăng nhập',
//                             prefixIcon: const Icon(Icons.person_outline),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           validator: (v) => (v == null || v.isEmpty)
//                               ? 'Vui lòng nhập tên đăng nhập'
//                               : null,
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _passwordController,
//                           obscureText: !_isPasswordVisible,
//                           decoration: InputDecoration(
//                             labelText: 'Mật khẩu',
//                             prefixIcon: const Icon(Icons.lock_outline),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   _isPasswordVisible = !_isPasswordVisible;
//                                 });
//                               },
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           validator: (v) =>
//                               (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
//                           onFieldSubmitted: (_) {
//                             if (!isLoading) _submitLogin();
//                           },
//                         ),
//                         const SizedBox(height: 12),
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: Text(
//                             'Quên mật khẩu?',
//                             style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w500),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         SizedBox(
//                           height: 48,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: primaryGreen,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             onPressed: isLoading ? null : _submitLogin,
//                             child: isLoading
//                                 ? const SizedBox(
//                                     height: 22,
//                                     width: 22,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       color: Colors.white,
//                                     ),
//                                   )
//                                 : const Text('ĐĂNG NHẬP'),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: const [
//                             Expanded(child: Divider()),
//                             Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 8.0),
//                               child: Text('hoặc'),
//                             ),
//                             Expanded(child: Divider()),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Text('Chưa có tài khoản?'),
//                             TextButton(
//                               onPressed: _navigateToRegister,
//                               style: TextButton.styleFrom(foregroundColor: accentRed),
//                               child: const Text('Đăng ký ngay'),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           '',
//                           textAlign: TextAlign.center,
//                           style: Theme.of(context).textTheme.bodySmall,
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

// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/providers/auth_provider.dart';
import 'package:hospital_app/providers/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  static const Color kPrimary = Color(0xFF0BA5A4);
  static const Color kAccent = Color(0xFF22C55E);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authProvider.notifier).login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  void _navigateToRegister() => context.push('/register');

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
            child: LayoutBuilder(builder: (context, constraints) {
              // co giãn max theo màn
              final double cardWidth = constraints.maxWidth < 380
    ? constraints.maxWidth
    : (constraints.maxWidth * 0.9).clamp(320.0, 420.0).toDouble();


              return Center(
                child: SizedBox(
                  width: cardWidth,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Color(0xFFE6F6F6),
                                  child: Icon(Icons.local_hospital_rounded,
                                      color: kPrimary),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Hospital App',
                                  style: TextStyle(
                                    color: kPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Kết nối để chăm sóc sức khỏe tốt hơn ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimary),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Đăng nhập để tiếp tục',
                              style: TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _usernameController,
                              textInputAction: TextInputAction.next,
                              decoration: _inputDecoration(
                                  label: 'Tên đăng nhập',
                                  icon: Icons.person_outline_rounded),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Vui lòng nhập tên đăng nhập'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: _inputDecoration(
                                label: 'Mật khẩu',
                                icon: Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  icon: Icon(_isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(() =>
                                      _isPasswordVisible = !_isPasswordVisible),
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Vui lòng nhập mật khẩu'
                                  : null,
                              onFieldSubmitted: (_) {
                                if (!isLoading) _submitLogin();
                              },
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  foregroundColor: kPrimary,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                child: const Text(''),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 48,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: isLoading ? null : _submitLogin,
                                child: isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : const Text('ĐĂNG NHẬP',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                    child: Container(
                                        height: 1, color: Colors.black12)),
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  child: Text('hoặc'),
                                ),
                                Expanded(
                                    child: Container(
                                        height: 1, color: Colors.black12)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Chưa có tài khoản?'),
                                TextButton(
                                  onPressed: _navigateToRegister,
                                  style: TextButton.styleFrom(
                                      foregroundColor: kAccent),
                                  child: const Text(
                                    'Đăng ký ngay',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '© ${DateTime.now().year} Hospital App',
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(color: Colors.black45),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: kPrimary),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF4F9F9),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: kPrimary.withOpacity(.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimary, width: 1.3),
      ),
    );
  }
}
