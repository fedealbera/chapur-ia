import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.productType,
    required super.articleCode,
    required super.name,
    required super.description,
    required super.brandCode,
    required super.brandName,
    required super.unitPrice,
    required super.priceListCode,
    required super.imageUrl,
    required super.stockStatus,
    required super.stockQuantity,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productType: json['productType']?.toString() ?? '',
      articleCode: json['articleCode']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      brandCode: (json['brandCode'] as num?)?.toInt() ?? 0,
      brandName: json['brandName']?.toString() ?? '',
      unitPrice: (json['price'] as num? ?? json['unitPrice'] as num? ?? 0.0).toDouble(),
      priceListCode: json['priceListCode']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      stockStatus: json['stockStatus']?.toString() ?? '',
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productType': productType,
      'articleCode': articleCode,
      'name': name,
      'description': description,
      'brandCode': brandCode,
      'brandName': brandName,
      'unitPrice': unitPrice,
      'priceListCode': priceListCode,
      'imageUrl': imageUrl,
      'stockStatus': stockStatus,
      'stockQuantity': stockQuantity,
    };
  }
}
