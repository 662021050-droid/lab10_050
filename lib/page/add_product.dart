import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lab10_050/models/boookmodel.dart'; // ตรวจสอบ path model ของคุณ
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddProduct extends StatefulWidget {
  final BookModel? book; // 👈 เพิ่ม: รับค่า book (ถ้ามีแปลว่าแก้ไข)
  const AddProduct({super.key, this.book});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    // 👈 ถ้ามีข้อมูล book ส่งมา ให้ใส่ค่าเริ่มต้นใน Controller
    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _yearController.text = widget.book!.publishedYear.toString();
    }
  }

  Future<void> saveProduct() async {
    SharedPreferences prefs = await _prefs;
    final token = prefs.getString("token") ?? "";

    var data = jsonEncode({
      "title": _titleController.text,
      "author": _authorController.text,
      "published_year": int.parse(_yearController.text),
    });

    // 👈 เลือก URL และ Method ตามโหมด (เพิ่มหรือแก้ไข)
    Uri url;
    http.Response response;

    if (widget.book == null) {
      // โหมดเพิ่มใหม่
      url = Uri.parse("http://10.0.2.2:3000/api/books");
      response = await http.post(
        url,
        body: data,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );
    } else {
      // โหมดแก้ไข (ใช้ PUT และส่ง ID ไปด้วย)
      url = Uri.parse("http://10.0.2.2:3000/api/books/${widget.book!.id}");
      response = await http.put(
        url,
        body: data,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );
    }

    debugPrint("Response Status: ${response.statusCode}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (mounted) {
        Navigator.pop(
          context,
          true,
        ); // ส่ง true กลับไปเพื่อให้หน้าแรกสั่งรีเฟรช
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 👈 เปลี่ยนพาดหัวตามสถานะ
    String pageTitle = widget.book == null
        ? "เพิ่มหนังสือใหม่"
        : "แก้ไขข้อมูลหนังสือ";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: Text(
          pageTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInputLabel("ชื่อหนังสือ"),
                    TextFormField(
                      controller: _titleController,
                      decoration: _inputStyle(Icons.book, "ระบุชื่อหนังสือ"),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'กรุณากรอกชื่อหนังสือ'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildInputLabel("ชื่อผู้แต่ง"),
                    TextFormField(
                      controller: _authorController,
                      decoration: _inputStyle(Icons.person, "ระบุชื่อผู้แต่ง"),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'กรุณากรอกชื่อผู้แต่ง'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildInputLabel("ปีที่พิมพ์"),
                    TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: _inputStyle(
                        Icons.calendar_today,
                        "เช่น 2024",
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'กรุณากรอกปีที่พิมพ์'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF63A4FF)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      saveProduct();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    widget.book == null ? "บันทึกข้อมูล" : "อัปเดตข้อมูล",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget อื่นๆ (_buildInputLabel, _inputStyle) โครงสร้างเดิมของคุณ ---
  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF334E68),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(IconData icon, String hint) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF4A90E2)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE1E8EE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 1.5),
      ),
    );
  }
}
