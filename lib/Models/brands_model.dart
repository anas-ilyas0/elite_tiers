// To parse this JSON data, do
//
//     final brandsModel = brandsModelFromJson(jsonString);

//import 'package:meta/meta.dart';
import 'dart:convert';

BrandsModel brandsModelFromJson(String str) =>
    BrandsModel.fromJson(json.decode(str));

String brandsModelToJson(BrandsModel data) => json.encode(data.toJson());

class BrandsModel {
  bool success;
  String message;
  List<Brands> data;

  BrandsModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BrandsModel.fromJson(Map<String, dynamic> json) => BrandsModel(
        success: json["success"],
        message: json["message"],
        data: List<Brands>.from(json["data"].map((x) => Brands.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Brands {
  int id;
  String enBrandName;
  String frBrandName;
  String enBrandSlug;
  String frBrandSlug;
  String brandImage;
  String status;
  DateTime createdAt;
  DateTime updatedAt;

  Brands({
    required this.id,
    required this.enBrandName,
    required this.frBrandName,
    required this.enBrandSlug,
    required this.frBrandSlug,
    required this.brandImage,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Brands.fromJson(Map<String, dynamic> json) => Brands(
        id: json["id"] ?? 0,
        enBrandName: json["en_BrandName"] ?? '',
        frBrandName: json["fr_BrandName"] ?? '',
        enBrandSlug: json["en_BrandSlug"] ?? '',
        frBrandSlug: json["fr_BrandSlug"] ?? '',
        brandImage: json["BrandImage"] ?? '',
        status: json["Status"] ?? '',
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "en_BrandName": enBrandName,
        "fr_BrandName": frBrandName,
        "en_BrandSlug": enBrandSlug,
        "fr_BrandSlug": frBrandSlug,
        "BrandImage": brandImage,
        "Status": status,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
