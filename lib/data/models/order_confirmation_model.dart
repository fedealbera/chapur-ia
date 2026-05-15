import '../../domain/entities/order_confirmation.dart';

class OrderConfirmationModel extends OrderConfirmation {
  OrderConfirmationModel({
    required super.orderId,
    required super.orderNumber,
    required super.legacyOrderId,
    required super.softlandId,
  });

  factory OrderConfirmationModel.fromJson(Map<String, dynamic> json) {
    return OrderConfirmationModel(
      orderId: json['orderId']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      legacyOrderId: json['legacyOrderId']?.toString() ?? '',
      softlandId: json['softlandId']?.toString() ?? '',
    );
  }
}
