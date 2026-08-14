import 'package:chapur_ia/core/constants/constants.dart';
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
      imageUrl: json['imageUrl']?.toString() ?? 
                '${AppConstants.productImageBaseUrl}${(json['articleCode']?.toString() ?? '').trim()}.jpg',
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
    super.iva21Usd,
    super.iva105Usd,
    super.customerAccountNumber,
    super.customerName,
    super.shippingLabel,
    super.shippingFree,
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
      iva21Usd: (json['iva21Usd'] as num?)?.toDouble() ?? 0.0,
      iva105Usd: (json['iva105Usd'] as num?)?.toDouble() ?? 0.0,
      customerAccountNumber: json['customerAccountNumber']?.toString() ?? json['customer']?['accountNumber']?.toString(),
      customerName: json['customerName']?.toString() ?? json['customer']?['name']?.toString(),
      shippingLabel: json['shippingLabel']?.toString() ?? json['customer']?['shippingLabel']?.toString(),
      shippingFree: json['shippingFree'] as bool? ?? json['customer']?['shippingFree'] as bool?,
    );
  }

  @override
  CartModel copyWith({
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
    return CartModel(
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
