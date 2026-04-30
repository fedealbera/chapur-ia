import 'package:equatable/equatable.dart';
import 'cart_item.dart';

class Cart extends Equatable {
  final List<CartItem> items;
  final double totalAmount;

  const Cart({
    required this.items,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [items, totalAmount];

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}
