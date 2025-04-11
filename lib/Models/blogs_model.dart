// To parse this JSON data, do
//
//     final blogsModel = blogsModelFromJson(jsonString);

//import 'package:meta/meta.dart';
import 'dart:convert';

BlogsModel blogsModelFromJson(String str) =>
    BlogsModel.fromJson(json.decode(str));

String blogsModelToJson(BlogsModel data) => json.encode(data.toJson());

class BlogsModel {
  bool success;
  String message;
  List<Blogs> data;

  BlogsModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BlogsModel.fromJson(Map<String, dynamic> json) => BlogsModel(
        success: json["success"],
        message: json["message"],
        data: List<Blogs>.from(json["data"].map((x) => Blogs.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Blogs {
  int id;
  //Tags tags;
  String smallImage;
  String bigImage;
  String enTitle;
  String enDescriptionOne;
  String enDescriptionTwo;
  String frTitle;
  String frDescriptionOne;
  String frDescriptionTwo;
  int userId;
  DateTime createdAt;
  DateTime updatedAt;

  Blogs({
    required this.id,
    //required this.tags,
    required this.smallImage,
    required this.bigImage,
    required this.enTitle,
    required this.enDescriptionOne,
    required this.enDescriptionTwo,
    required this.frTitle,
    required this.frDescriptionOne,
    required this.frDescriptionTwo,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Blogs.fromJson(Map<String, dynamic> json) => Blogs(
        id: json["id"] ?? 0,
        //tags: Tags.fromJson(json["tags"]),
        smallImage: json["Small_Image"] ?? '',
        bigImage: json["Big_Image"] ?? '',
        enTitle: json["en_Title"] ?? '',
        enDescriptionOne: json["en_Description_One"] ?? '',
        enDescriptionTwo: json["en_Description_Two"] ?? '',
        frTitle: json["fr_Title"] ?? '',
        frDescriptionOne: json["fr_Description_One"] ?? '',
        frDescriptionTwo: json["fr_Description_Two"] ?? '',
        userId: json["user_id"] ?? 0,
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        //"tags": tags.toJson(),
        "Small_Image": smallImage,
        "Big_Image": bigImage,
        "en_Title": enTitle,
        "en_Description_One": enDescriptionOne,
        "en_Description_Two": enDescriptionTwo,
        "fr_Title": frTitle,
        "fr_Description_One": frDescriptionOne,
        "fr_Description_Two": frDescriptionTwo,
        "user_id": userId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

// class Tags {
//   int id;
//   int blogId;
//   List<String> tag;
//   DateTime createdAt;
//   DateTime updatedAt;

//   Tags({
//     required this.id,
//     required this.blogId,
//     required this.tag,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory Tags.fromJson(Map<String, dynamic> json) => Tags(
//         id: json["id"] ?? 0,
//         blogId: json["blog_id"] ?? 0,
//         tag: List<String>.from(json["Tag"].map((x) => x) ?? []),
//         createdAt: DateTime.parse(json["created_at"]),
//         updatedAt: DateTime.parse(json["updated_at"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "blog_id": blogId,
//         "Tag": List<dynamic>.from(tag.map((x) => x)),
//         "created_at": createdAt.toIso8601String(),
//         "updated_at": updatedAt.toIso8601String(),
//       };
// }
