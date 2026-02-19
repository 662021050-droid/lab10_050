import 'package:flutter/material.dart';
import 'package:lab10_050/page/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // แก้ไขจุดที่ 1: เติม ColorScheme นำหน้า .fromSeed
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // แก้ไขจุดที่ 2: ถ้ายังไม่ได้สร้าง LoginPage ให้ใช้ MyHomePage ไปก่อนครับ
      home: const LoginPage(),
    );
  }
}
