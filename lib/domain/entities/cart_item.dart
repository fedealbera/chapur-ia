import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String articleCode;
  final int quantity;
  final String? description;
  final double? unitPrice;
  final double? subtotal;
  // USD fields from API
  final double? priceUsd;
  final double? subtotalUsd;
  final double? ivaRate;
  final double? ivaAmount;
  final double? ivaAmountUsd;
  final String? stockStatus;
  final String? imageUrl;

  const CartItem({
    required this.articleCode,
    required this.quantity,
    this.description,
    this.unitPrice,
    this.subtotal,
    this.priceUsd,
    this.subtotalUsd,
    this.ivaRate,
    this.ivaAmount,
    this.ivaAmountUsd,
    this.stockStatus,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        articleCode,
        quantity,
        description,
        unitPrice,
        subtotal,
        priceUsd,
        subtotalUsd,
        ivaRate,
        ivaAmount,
        ivaAmountUsd,
        stockStatus,
        imageUrl,
      ];

  CartItem copyWith({
    String? articleCode,
    int? quantity,
    String? description,
    double? unitPrice,
    double? subtotal,
    double? priceUsd,
    double? subtotalUsd,
    double? ivaRate,
    double? ivaAmount,
    double? ivaAmountUsd,
    String? stockStatus,
    String? imageUrl,
  }) {
    return CartItem(
      articleCode: articleCode ?? this.articleCode,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      priceUsd: priceUsd ?? this.priceUsd,
      subtotalUsd: subtotalUsd ?? this.subtotalUsd,
      ivaRate: ivaRate ?? this.ivaRate,
      ivaAmount: ivaAmount ?? this.ivaAmount,
      ivaAmountUsd: ivaAmountUsd ?? this.ivaAmountUsd,
      stockStatus: stockStatus ?? this.stockStatus,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
