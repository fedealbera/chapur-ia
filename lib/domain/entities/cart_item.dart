import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String articleCode;
  final int quantity;
  final String? name;
  final double? unitPrice;

  const CartItem({
    required this.articleCode,
    required this.quantity,
    this.name,
    this.unitPrice,
  });

  @override
  List<Object?> get props => [articleCode, quantity, name, unitPrice];

  CartItem copyWith({
    String? articleCode,
    int? quantity,
    String? name,
    double? unitPrice,
  }) {
    return CartItem(
      articleCode: articleCode ?? this.articleCode,
      quantity: quantity ?? this.quantity,
      name: name ?? this.name,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
