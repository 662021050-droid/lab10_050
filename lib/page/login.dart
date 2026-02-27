import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'show_products.dart'; // ตรวจสอบชื่อไฟล์ให้ถูกต้อง

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
          // พื้นหลังวงกลม
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

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
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
                    _buildTextField(
                      _usernameController,
                      "ชื่อผู้ใช้งาน",
                      Icons.person_outline,
                      false,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      _passwordController,
                      "รหัสผ่าน",
                      Icons.lock_outline,
                      true,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) _handleLogin();
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    var url = Uri.parse("http://10.0.2.2:3000/api/auth/login");
    try {
      var response = await http.post(
        url,
        body: jsonEncode({
          "username": _usernameController.text,
          "password": _passwordController.text,
        }),
        headers: {HttpHeaders.contentTypeHeader: "application/json"},
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        String? token =
            responseData['token'] ??
            responseData['accessToken'] ??
            responseData['payload']?['token'];
        if (token != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ShowProducts()),
            );
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Widget _buildCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color.withOpacity(0.6),
      shape: BoxShape.circle,
    ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool isPassword,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _isObscure : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[300]),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _isObscure = !_isObscure),
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFE1E8EE)),
        ),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? 'กรุณากรอก$label' : null,
    );
  }
}
