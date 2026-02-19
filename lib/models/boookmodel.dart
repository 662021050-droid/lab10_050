// To parse this JSON data, do
//
//     final bookmodel = bookmodelFromJson(jsonString);

import 'dart:convert';

Bookmodel bookmodelFromJson(String str) => Bookmodel.fromJson(json.decode(str));

String bookmodelToJson(Bookmodel data) => json.encode(data.toJson());

class Bookmodel {
  int id;
  String title;
  String author;
  int publishedYear;

  Bookmodel({
    required this.id,
    required this.title,
    required this.author,
    required this.publishedYear,
  });

  factory Bookmodel.fromJson(Map<String, dynamic> json) => Bookmodel(
    id: json["id"],
    title: json["title"],
    author: json["author"],
    publishedYear: json["published_year"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "author": author,
    "published_year": publishedYear,
  };
}
