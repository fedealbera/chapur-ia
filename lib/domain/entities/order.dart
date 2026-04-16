import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final String articleCode;
  final String description;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const OrderItem({
    required this.articleCode,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [
        articleCode,
        description,
        quantity,
        unitPrice,
        subtotal,
      ];
}

class Order extends Equatable {
  final String id;
  final String orderNumber;
  final String legacyOrderId;
  final String customerAccountNumber;
  final String customerName;
  final DateTime date;
  final String status;
  final double total;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.legacyOrderId,
    required this.customerAccountNumber,
    required this.customerName,
    required this.date,
    required this.status,
    required this.total,
    required this.items,
  });

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        legacyOrderId,
        customerAccountNumber,
        customerName,
        date,
        status,
        total,
        items,
      ];
}
