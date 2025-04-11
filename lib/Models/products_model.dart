import 'dart:convert';

ProductsModel productsModelFromJson(String str) =>
    ProductsModel.fromJson(json.decode(str));

String productsModelToJson(ProductsModel data) => json.encode(data.toJson());

class ProductsModel {
  bool success;
  String message;
  List<ProductsCategories> data;

  ProductsModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProductsModel.fromJson(Map<String, dynamic> json) => ProductsModel(
        success: json["success"],
        message: json["message"],
        data: List<ProductsCategories>.from(
            json["data"].map((x) => ProductsCategories.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<ProductsCategories>.from(data.map((x) => x.toJson())),
      };
}

class ProductsCategories {
  int id;
  String name;
  String image;
  String description;
  DateTime createdAt;
  DateTime updatedAt;
  List<AllProducts> products;

  ProductsCategories({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.products,
  });

  factory ProductsCategories.fromJson(Map<String, dynamic> json) =>
      ProductsCategories(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
        image: json['image'] ?? '',
        description: json["description"] ?? '',
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        products: List<AllProducts>.from(
            json["products"].map((x) => AllProducts.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "description": description,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
      };
}

class AllProducts {
  int id;
  String enProductName;
  String frProductName;
  String enBrand;
  String frBrand;
  //String sku;
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
  DateTime createdAt;
  DateTime updatedAt;

  AllProducts({
    required this.id,
    required this.enProductName,
    required this.frProductName,
    required this.enBrand,
    required this.frBrand,
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory AllProducts.fromJson(Map<String, dynamic> json) => AllProducts(
        id: json["id"] ?? 0,
        enProductName: json["en_Product_Name"] ?? '',
        frProductName: json["fr_Product_Name"] ?? '',
        enBrand: json['en_brand'] ?? '',
        frBrand: json['fr_brand'] ?? '',
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
        createdAt: DateTime.parse(json["created_at"] ?? ''),
        updatedAt: DateTime.parse(json["updated_at"] ?? ''),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "en_Product_Name": enProductName,
        "fr_Product_Name": frProductName,
        "en_brand": enBrand,
        "fr_brand": frBrand,
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
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
