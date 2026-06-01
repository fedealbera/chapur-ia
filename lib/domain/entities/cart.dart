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
  final String? shippingLabel;
  final bool? shippingFree;

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
    this.shippingLabel,
    this.shippingFree,
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
        shippingLabel,
        shippingFree,
      ];

  int get totalItems => items.length;

  // For backward compatibility or convenience
  double get totalAmount => grandTotal;

  Cart copyWith({
    List<CartItem>? items,
    double? subtotal,
    double? ivaTotal,
    double? grandTotal,
    double? subtotalUsd,
    double? ivaTotalUsd,
    double? grandTotalUsd,
    double? iva21Usd,
    double? iva105Usd,
    String? customerAccountNumber,
    String? customerName,
    String? shippingLabel,
    bool? shippingFree,
  }) {
    return Cart(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      ivaTotal: ivaTotal ?? this.ivaTotal,
      grandTotal: grandTotal ?? this.grandTotal,
      subtotalUsd: subtotalUsd ?? this.subtotalUsd,
      ivaTotalUsd: ivaTotalUsd ?? this.ivaTotalUsd,
      grandTotalUsd: grandTotalUsd ?? this.grandTotalUsd,
      iva21Usd: iva21Usd ?? this.iva21Usd,
      iva105Usd: iva105Usd ?? this.iva105Usd,
      customerAccountNumber: customerAccountNumber ?? this.customerAccountNumber,
      customerName: customerName ?? this.customerName,
      shippingLabel: shippingLabel ?? this.shippingLabel,
      shippingFree: shippingFree ?? this.shippingFree,
    );
  }
}
