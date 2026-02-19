import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lab10_050/models/boookmodel.dart';

class ShowProducts extends StatefulWidget {
  const ShowProducts({super.key});

  @override
  State<ShowProducts> createState() => ShowProductsState();
}

class ShowProductsState extends State<ShowProducts> {
  List<Bookmodel>? book;
  @override
  void initState() {
    super.initState();
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

Future<void> getList() async {
  Books = [];     
  var url =Uri.parse("http://localhost:8080/api/books");
  var response = await http.get(url,header:{
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.authorizationHeader: "Bearer ${token}" 
  });
  var.jsonStr=jsonDecode(response.body);
  var jsonStr;
  books =jsonStr['payload'].map((e) => Bookmodel.fromJson(e)).toList();
  setState(() {});
}


