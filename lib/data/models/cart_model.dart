import 'package:chapur_ia/domain/entities/cart.dart';
import 'package:chapur_ia/domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.articleCode,
    required super.quantity,
    super.name,
    super.unitPrice,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      articleCode: json['articleCode']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString(),
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
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
    required super.totalAmount,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List?)
            ?.map((i) => CartItemModel.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];
    return CartModel(
      items: itemsList,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
