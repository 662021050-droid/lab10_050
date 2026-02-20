// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lab10_050/page/show_products.dart' show ShowProducts;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(
  const MaterialApp(home: LoginPage(), debugShowCheckedModeBanner: false),
);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- 1. ส่วนพื้นหลังวงกลมพาสเทล (ดีไซน์เดิมที่คุณต้องการ) ---
          Positioned(
            top: -50,
            left: -50,
            child: _buildCircle(200, Colors.blue[100]!),
          ),
          Positioned(
            bottom: -80,
            right: -20,
            child: _buildCircle(250, Colors.purple[100]!),
          ),
          Positioned(
            top: 200,
            right: -40,
            child: _buildCircle(150, Colors.pink[100]!),
          ),

          // --- 2. ส่วนเนื้อหา Login ---
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Welcome",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "กรุณาเข้าสู่ระบบเพื่อใช้งาน",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 40),

                      // Username Field
                      TextFormField(
                        controller: _usernameController,
                        decoration: _inputDecoration(
                          "ชื่อผู้ใช้งาน",
                          Icons.person_outline,
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'กรุณากรอกชื่อผู้ใช้งาน'
                            : null,
                      ),
                      const SizedBox(height: 15),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        decoration:
                            _inputDecoration(
                              "รหัสผ่าน",
                              Icons.lock_outline,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () =>
                                    setState(() => _isObscure = !_isObscure),
                              ),
                            ),
                        validator: (value) =>
                            (value == null || value.length < 4)
                            ? 'รหัสผ่านอย่างน้อย 4 ตัว'
                            : null,
                      ),
                      const SizedBox(height: 30),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _handleLogin();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[200],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "เข้าสู่ระบบ",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Register Link
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.purple[300],
                        ),
                        child: const Text("ยังไม่มีบัญชี? สมัครสมาชิก"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันจัดการการ Login
  Future<void> _handleLogin() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('กำลังเข้าสู่ระบบ...')));

    var jsonBody = jsonEncode({
      "username": _usernameController.text,
      "password": _passwordController.text,
    });

    var url = Uri.parse("http://10.0.2.2:3000/api/auth/login");

    try {
      var response = await http.post(
        url,
        body: jsonBody,
        headers: {HttpHeaders.contentTypeHeader: "application/json"},
      );

      debugPrint("Response: ${response.body}");

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        var payload = responseData['payload'];

        // ดึง Token (รองรับทั้งชื่อ accessToken หรือดึงจาก payload)
        String? token = responseData['accessToken'] ?? payload?['token'];

        if (token != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          // บันทึกข้อมูล User และ Token
          await prefs.setStringList('user', [
            payload['username'].toString(),
            payload['tel']?.toString() ?? "",
          ]);
          await prefs.setString('token', token);

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ShowProducts()),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // Helper สร้างวงกลมพื้นหลัง
  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
    );
  }

  // ปรับแต่ง Input ให้เข้ากับดีไซน์วงกลม (ขอบมน 30)
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue[300]),
      filled: true,
      fillColor: Colors.white.withOpacity(0.8),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFFE1E8EE)),
      ),
    );
  }
}
