import '../../domain/entities/order.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.articleCode,
    required super.description,
    required super.quantity,
    required super.unitPrice,
    required super.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      articleCode: json['articleCode'],
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'articleCode': articleCode,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
    };
  }
}

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.orderNumber,
    required super.legacyOrderId,
    required super.customerAccountNumber,
    required super.customerName,
    required super.date,
    required super.status,
    required super.total,
    required super.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      orderNumber: json['orderNumber'],
      legacyOrderId: json['legacyOrderId'],
      customerAccountNumber: json['customerAccountNumber'],
      customerName: json['customerName'],
      date: DateTime.parse(json['date']),
      status: json['status'],
      total: (json['total'] as num).toDouble(),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'legacyOrderId': legacyOrderId,
      'customerAccountNumber': customerAccountNumber,
      'customerName': customerName,
      'date': date.toIso8601String(),
      'status': status,
      'total': total,
      'items': items.map((item) => (item as OrderItemModel).toJson()).toList(),
    };
  }
}
