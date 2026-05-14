import 'package:chapur_ia/domain/entities/cart.dart';
import 'package:chapur_ia/domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.articleCode,
    required super.quantity,
    super.description,
    super.unitPrice,
    super.subtotal,
    super.priceUsd,
    super.subtotalUsd,
    super.ivaRate,
    super.ivaAmount,
    super.ivaAmountUsd,
    super.stockStatus,
    super.imageUrl,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      articleCode: json['articleCode']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString(),
      unitPrice: (json['price'] as num?)?.toDouble(),
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      priceUsd: (json['priceUsd'] as num?)?.toDouble(),
      subtotalUsd: (json['subtotalUsd'] as num?)?.toDouble(),
      ivaRate: (json['ivaRate'] as num?)?.toDouble(),
      ivaAmount: (json['ivaAmount'] as num?)?.toDouble(),
      ivaAmountUsd: (json['ivaAmountUsd'] as num?)?.toDouble(),
      stockStatus: json['stockStatus']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'articleCode': articleCode,
      'quantity': quantity,
    };
  }
}

class CartModel extends Cart {
  const CartModel({
    required super.items,
    required super.subtotal,
    required super.ivaTotal,
    required super.grandTotal,
    super.subtotalUsd,
    super.ivaTotalUsd,
    super.grandTotalUsd,
    super.customerAccountNumber,
    super.customerName,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List?)
            ?.map((i) => CartItemModel.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];
    return CartModel(
      items: itemsList,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      ivaTotal: (json['ivaTotal'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      subtotalUsd: (json['subtotalUsd'] as num?)?.toDouble() ?? 0.0,
      ivaTotalUsd: (json['ivaTotalUsd'] as num?)?.toDouble() ?? 0.0,
      grandTotalUsd: (json['grandTotalUsd'] as num?)?.toDouble() ?? 0.0,
      customerAccountNumber: json['customerAccountNumber']?.toString(),
      customerName: json['customerName']?.toString(),
    );
  }
}
