// // lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hospital_app/core/router.dart'; // 1. Import router
// import 'package:flutter_localizations/flutter_localizations.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env");

//   runApp(
//     const ProviderScope(
//       child: MyApp(),
//     ),
//   );
// }

// // 2. Chuyển MyApp thành ConsumerWidget để có thể truy cập provider
// class MyApp extends ConsumerWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // 3. Lấy router từ provider
//     final router = ref.watch(routerProvider);

//     // 4. Sử dụng routerConfig thay vì home
//     return MaterialApp.router(
//       title: 'Hospital App',
//       // <<< THÊM CÁC DÒNG NÀY >>>
//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: const [
//         Locale('vi', 'VN'), // Vietnamese
//         // ... other locales the app supports
//       ],
//       locale: const Locale('vi', 'VN'), // Đặt locale mặc định
//       // <<< KẾT THÚC PHẦN THÊM >>>
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       routerConfig: router,
//     );
//   }
// }
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Màu xanh y tế (emerald)
    const medicalGreen = Color.fromARGB(255, 241, 249, 244);

    return MaterialApp.router(
      title: 'Hospital App',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi', 'VN')],
      locale: const Locale('vi', 'VN'),

      // 🔹 Material 3 + ColorScheme từ seed (thay cho primarySwatch)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: medicalGreen,
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(elevation: 1.5),
        chipTheme: const ChipThemeData(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),

      // (Tuỳ chọn) Dark theme đồng bộ xanh lá
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: medicalGreen,
          brightness: Brightness.dark,
        ),
      ),

      themeMode: ThemeMode.light, // hoặc ThemeMode.system nếu muốn theo máy
      routerConfig: router,
    );
  }
}
