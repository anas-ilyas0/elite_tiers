// To parse this JSON data, do
//
//     final categoryModel = categoryModelFromJson(jsonString);

//import 'package:meta/meta.dart';
import 'dart:convert';

CategoryModel categoryModelFromJson(String str) =>
    CategoryModel.fromJson(json.decode(str));

String categoryModelToJson(CategoryModel data) => json.encode(data.toJson());

class CategoryModel {
  bool success;
  String message;
  List<CategoryData> data;

  CategoryModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        success: json["success"],
        message: json["message"],
        data: List<CategoryData>.from(
            json["data"].map((x) => CategoryData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class CategoryData {
  int id;
  String name;
  String enCategoryName;
  String frCategoryName;
  String enCategorySlug;
  String frCategorySlug;
  String categoryIcon;
  String enDescription;
  String frDescription;
  String image;
  int status;
  DateTime createdAt;
  DateTime updatedAt;

  CategoryData({
    required this.id,
    required this.name,
    required this.enCategoryName,
    required this.frCategoryName,
    required this.enCategorySlug,
    required this.frCategorySlug,
    required this.categoryIcon,
    required this.enDescription,
    required this.frDescription,
    required this.image,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) => CategoryData(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
        enCategoryName: json["en_Category_Name"] ?? '',
        frCategoryName: json["fr_Category_Name"] ?? '',
        enCategorySlug: json["en_Category_Slug"] ?? '',
        frCategorySlug: json["fr_Category_Slug"] ?? '',
        categoryIcon: json["Category_Icon"] ?? '',
        enDescription: json["en_Description"] ?? '',
        frDescription: json["fr_Description"] ?? '',
        image: json["image"] ?? '',
        status: json["Status"] ?? 0,
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "en_Category_Name": enCategoryName,
        "fr_Category_Name": frCategoryName,
        "en_Category_Slug": enCategorySlug,
        "fr_Category_Slug": frCategorySlug,
        "Category_Icon": categoryIcon,
        "en_Description": enDescription,
        "fr_Description": frDescription,
        "image": image,
        "Status": status,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
