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
      productType: json['productType'],
      articleCode: json['articleCode'],
      name: json['name'],
      description: json['description'],
      brandCode: json['brandCode'],
      brandName: json['brandName'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      priceListCode: json['priceListCode'],
      imageUrl: json['imageUrl'] ?? '',
      stockStatus: json['stockStatus'],
      stockQuantity: json['stockQuantity'],
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
