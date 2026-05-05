import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String articleCode;
  final int quantity;
  final String? description;
  final double? unitPrice;
  final double? subtotal;

  const CartItem({
    required this.articleCode,
    required this.quantity,
    this.description,
    this.unitPrice,
    this.subtotal,
  });

  @override
  List<Object?> get props => [articleCode, quantity, description, unitPrice, subtotal];

  CartItem copyWith({
    String? articleCode,
    int? quantity,
    String? description,
    double? unitPrice,
    double? subtotal,
  }) {
    return CartItem(
      articleCode: articleCode ?? this.articleCode,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}
