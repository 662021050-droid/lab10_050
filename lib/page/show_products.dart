import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/boookmodel.dart';
import 'login.dart';
import 'add_product.dart';
import 'edit_product.dart';

class ShowProducts extends StatefulWidget {
  const ShowProducts({super.key});
  @override
  State<ShowProducts> createState() => _ShowProductsState();
}

class _ShowProductsState extends State<ShowProducts> {
  List<BookModel>? books;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getList();
  }

  // --- 1. ฟังก์ชันยืนยันก่อนออกจากระบบ ---
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("ออกจากระบบ"),
        content: const Text("คุณต้องการออกจากระบบใช่หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("ตกลง", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- 2. ฟังก์ชัน Logout ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      var url = Uri.parse('http://10.0.2.2:3000/api/auth/logout');
      await http
          .post(
            url,
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              HttpHeaders.authorizationHeader: 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint("Logout Error: $e");
    } finally {
      await prefs.clear();
      if (mounted) {
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  // --- 3. ฟังก์ชันดึงข้อมูลสินค้า ---
  Future<void> getList() async {
    try {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";
      var url = Uri.parse("http://10.0.2.2:3000/api/books");
      var response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          books = jsonList.map((item) => BookModel.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Fetch Data Error: $e");
      setState(() => isLoading = false);
    }
  }

  // --- 4. ฟังก์ชันลบสินค้า ---
  Future<void> deleteBook(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    var url = Uri.parse("http://10.0.2.2:3000/api/books/$id");

    try {
      var response = await http.delete(
        url,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        getList();
      }
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  // --- 5. ฟังก์ชันสำหรับกดที่ Card เพื่อไปหน้าแก้ไข ---
  void _editBook(BookModel book) async {
    // แก้ไขจาก editProduct เป็น EditProduct (ตัว E ใหญ่) ตามชื่อ Class ในไฟล์ edit_product.dart
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProduct(book: book)),
    );
    if (result == true) {
      getList();
    }
  }

  // --- 6. ส่วนสร้าง Card ---
  Widget _buildBookCard(BookModel book) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _editBook(book),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F9FF),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1E3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.book, color: Color(0xFF4A90E2)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "ผู้แต่ง: ${book.author}",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    Text(
                      "ปี: ${book.publishedYear}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _showDeleteDialog(book),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BookModel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยืนยันการลบ"),
        content: Text("คุณต้องการลบ '${book.title}' ใช่หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteBook(book.id);
            },
            child: const Text("ลบ", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Show Products"),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: getList,
              child: books == null || books!.isEmpty
                  ? const Center(child: Text("ไม่พบข้อมูลสินค้า"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: books!.length,
                      itemBuilder: (context, index) =>
                          _buildBookCard(books![index]),
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProduct()),
          ).then((value) {
            if (value == true) {
              getList();
            }
          });
        },
        backgroundColor: const Color(0xFF4A90E2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
