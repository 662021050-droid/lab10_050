import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(
  const MaterialApp(home: LoginPage(), debugShowCheckedModeBanner: false),
);

// เปลี่ยนเป็น StatefulWidget เพื่อให้หน้าจอจัดการสถานะของตัวอักษรสีแดงได้
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // สร้าง Key สำหรับจัดการ Form
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- 1. ส่วนพื้นหลังวงกลมพาสเทล ---
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
                  key: _formKey, // ครอบด้วย Form เพื่อให้ตรวจจับค่าว่างได้
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Welcome Thanapan",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Username TextField (เปลี่ยนจาก Email เป็น Username)
                      TextFormField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          hintText: "Username",
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "กรุณากรอก username";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Password TextField
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "กรุณากรอก password";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            // สั่งให้ตรวจสอบข้อมูลใน Form
                            if (_formKey.currentState!.validate()) {
                              debugPrint(
                                "Username: ${usernameController.text}",
                              );
                              debugPrint(
                                "Password: ${passwordController.text}",
                              );
                              var json = jsonEncode({
                                "username": usernameController.text,
                                "password": passwordController.text,
                              });
                              var url = Uri.parse(
                                "http://10.0.2.2:3000/api/auth/login",
                              );

                              var respose = await http.post(
                                url,
                                body: json,
                                headers: {
                                  HttpHeaders.contentTypeHeader:
                                      "application/json",
                                },
                              );
                              debugPrint(respose.body);

                              if (respose.statusCode == 200) {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              var userJson = jsonDecode(respose.body)["payload"];
                              var tokerJson = jsonDecode(respose.body)["payload"];
                              
                              await prefs.setString("user",[
                                userJson["username"],
                                userJson["tel"],
                              ] 
                            )
                              await prefs.setString("token", tokerJson);
                              debugPrint(tokerJson.toString());

                              Navigator.push(context,
                                MaterialPageRoute(builder: (context) => const ShowProduct()));
                              
                              // ถ้ากรอกครบแล้ว จะทำงานตรงนี้
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
                            "Login",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Register Button
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.purple[300],
                        ),
                        child: const Text("Don't have an account? Register"),
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

  // Helper สร้าง TextFormField (เพิ่ม validator สำหรับแสดงสีแดง)
  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required String errorMsg,
    bool isPassword = false,
  }) {
    return TextFormField(
      obscureText: isPassword,
      // ส่วนที่ใช้ตรวจสอบค่าว่าง
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorMsg; // ส่งข้อความแจ้งเตือนสีแดงกลับไป
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        // ปรับแต่งขอบปกติ
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        // ปรับแต่งสีข้อความตอน Error ให้เป็นสีแดง
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
