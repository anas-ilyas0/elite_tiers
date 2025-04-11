// To parse this JSON data, do
//
//     final dealModel = dealModelFromJson(jsonString);

//import 'package:meta/meta.dart';
import 'dart:convert';

DealModel dealModelFromJson(String str) => DealModel.fromJson(json.decode(str));

String dealModelToJson(DealModel data) => json.encode(data.toJson());

class DealModel {
  bool success;
  String message;
  Deal data;

  DealModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DealModel.fromJson(Map<String, dynamic> json) => DealModel(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        data: Deal.fromJson(json["data"] ?? []),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.toJson(),
      };
}

class Deal {
  int id;
  String category;
  String enProductName;
  String frProductName;
//  String sku;
  String price;
  String discountPrice;
  String tag;
  String origin;
  String year;
  String width;
  String ratio;
  String pattern;
  String rimSize;
  String enDescription;
  String frDescription;
  String diameter;
  String primaryImage;
  // DateTime createdAt;
  // DateTime updatedAt;

  Deal({
    required this.id,
    required this.category,
    required this.enProductName,
    required this.frProductName,
    //required this.sku,
    required this.price,
    required this.discountPrice,
    required this.tag,
    required this.origin,
    required this.year,
    required this.width,
    required this.ratio,
    required this.pattern,
    required this.rimSize,
    required this.enDescription,
    required this.frDescription,
    required this.diameter,
    required this.primaryImage,
    // required this.createdAt,
    // required this.updatedAt,
  });

  factory Deal.fromJson(Map<String, dynamic> json) => Deal(
        id: json["id"] ?? 0,
        category: json["category"] ?? '',
        enProductName: json["en_Product_Name"] ?? '',
        frProductName: json["fr_Product_Name"] ?? '',
        //sku: json["sku"] ?? '',
        price: json["price"] ?? '',
        discountPrice: json["discount_price"] ?? '',
        tag: json["tag"] ?? '',
        origin: json["origin"] ?? '',
        year: json["year"] ?? '',
        width: json["width"] ?? '',
        ratio: json["ratio"] ?? '',
        pattern: json["pattern"] ?? '',
        rimSize: json["rim_size"] ?? '',
        enDescription: json["en_Description"] ?? '',
        frDescription: json["fr_Description"] ?? '',
        diameter: json["diameter"] ?? '',
        primaryImage: json["primary_image"] ?? '',
        // createdAt: DateTime.parse(json["created_at"]),
        // updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "category": category,
        "en_Product_Name": enProductName,
        "fr_Product_Name": frProductName,
        //"sku": sku,
        "price": price,
        "discount_price": discountPrice,
        "tag": tag,
        "origin": origin,
        "year": year,
        "width": width,
        "ratio": ratio,
        "pattern": pattern,
        "rim_size": rimSize,
        "en_Description": enDescription,
        "fr_Description": frDescription,
        "diameter": diameter,
        "primary_image": primaryImage,
        //   "created_at": createdAt.toIso8601String(),
        //   "updated_at": updatedAt.toIso8601String(),
      };
}
