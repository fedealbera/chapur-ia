class CartModel {
  final List<CartItemModel> items;
  final double subtotal;
  final double taxes;
  final double total;
  final int itemCount;

  CartModel({
    required this.items,
    required this.subtotal,
    required this.taxes,
    required this.total,
    required this.itemCount,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxes: (json['taxes'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      itemCount: json['itemCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'taxes': taxes,
      'total': total,
      'itemCount': itemCount,
    };
  }
}

class CartItemModel {
  final String articleCode;
  final String description;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String? imageUrl;
  final String stockStatus;
  final int stockQuantity;

  CartItemModel({
    required this.articleCode,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.imageUrl,
    required this.stockStatus,
    required this.stockQuantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      articleCode: json['articleCode'] as String? ?? '',
      description: json['description'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
      stockStatus: json['stockStatus'] as String? ?? '',
      stockQuantity: json['stockQuantity'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'articleCode': articleCode,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
      'imageUrl': imageUrl,
      'stockStatus': stockStatus,
      'stockQuantity': stockQuantity,
    };
  }
}
