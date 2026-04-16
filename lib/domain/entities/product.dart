import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String productType;
  final String articleCode;
  final String name;
  final String description;
  final int brandCode;
  final String brandName;
  final double unitPrice;
  final String priceListCode;
  final String imageUrl;
  final String stockStatus; // VERDE, AMARILLO, ROJO
  final int stockQuantity;

  const Product({
    required this.productType,
    required this.articleCode,
    required this.name,
    required this.description,
    required this.brandCode,
    required this.brandName,
    required this.unitPrice,
    required this.priceListCode,
    required this.imageUrl,
    required this.stockStatus,
    required this.stockQuantity,
  });

  @override
  List<Object?> get props => [
        productType,
        articleCode,
        name,
        description,
        brandCode,
        brandName,
        unitPrice,
        priceListCode,
        imageUrl,
        stockStatus,
        stockQuantity,
      ];
}
