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
      articleCode: json['articleCode']?.toString() ?? json['productCode']?.toString() ?? '',
      description: json['description']?.toString() ?? json['productName']?.toString() ?? json['name']?.toString() ?? '',
      quantity: json['quantity'] ?? json['qty'] ?? 0,
      unitPrice: ((json['unitPrice'] ?? json['price'] ?? 0) as num).toDouble(),
      subtotal: ((json['subtotal'] ?? json['amount'] ?? json['total'] ?? 0) as num).toDouble(),
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
    final itemsList = json['items'] ?? json['lines'] ?? json['details'] ?? json['orderItems'];
    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      legacyOrderId: json['legacyOrderId']?.toString() ?? '',
      customerAccountNumber: json['customerAccountNumber']?.toString() ?? json['accountNumber']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? json['clientName']?.toString() ?? json['customer']?['name']?.toString() ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      status: json['status']?.toString() ?? '',
      total: ((json['total'] ?? json['totalAmount'] ?? 0) as num).toDouble(),
      items: (itemsList as List<dynamic>?)
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
