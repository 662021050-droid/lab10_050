import 'dart:convert';

BookModel bookModelFromJson(String str) => BookModel.fromJson(json.decode(str));

String bookModelToJson(BookModel data) => json.encode(data.toJson());

class BookModel {
  int id;
  String title;
  String author;
  int publishedYear;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.publishedYear,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
    id: json["id"] is String ? int.parse(json["id"]) : json["id"],
    title: json["title"].toString(),
    author: json["author"].toString(),
    // แก้จุดนี้: ใช้การเช็คประเภทข้อมูล (Data Type)
    publishedYear: json["published_year"] is String
        ? int.parse(json["published_year"])
        : json["published_year"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "author": author,
    "published_year": publishedYear,
  };
}
