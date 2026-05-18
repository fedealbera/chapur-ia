import 'package:equatable/equatable.dart';
import 'cart_item.dart';

class Cart extends Equatable {
  final List<CartItem> items;
  final double subtotal;
  final double ivaTotal;
  final double grandTotal;
  // USD totals from API
  final double subtotalUsd;
  final double ivaTotalUsd;
  final double grandTotalUsd;
  final double iva21Usd;
  final double iva105Usd;
  final String? customerAccountNumber;
  final String? customerName;

  const Cart({
    required this.items,
    required this.subtotal,
    required this.ivaTotal,
    required this.grandTotal,
    this.subtotalUsd = 0.0,
    this.ivaTotalUsd = 0.0,
    this.grandTotalUsd = 0.0,
    this.iva21Usd = 0.0,
    this.iva105Usd = 0.0,
    this.customerAccountNumber,
    this.customerName,
  });

  @override
  List<Object?> get props => [
        items,
        subtotal,
        ivaTotal,
        grandTotal,
        subtotalUsd,
        ivaTotalUsd,
        grandTotalUsd,
        iva21Usd,
        iva105Usd,
        customerAccountNumber,
        customerName,
      ];

  int get totalItems => items.length;

  // For backward compatibility or convenience
  double get totalAmount => grandTotal;
}
