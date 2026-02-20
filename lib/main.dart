import 'package:flutter/material.dart';
import 'package:lab10_050/page/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // กำหนดโทนสีฟ้า-น้ำเงินพาสเทล
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D9CEC),
          primary: const Color(0xFF4A90E2),
          secondary: const Color(0xFFD1E3FF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F9FF), // พื้นหลังฟ้าอ่อนมากๆ
      ),
      home: const LoginPage(),
    );
  }
}
