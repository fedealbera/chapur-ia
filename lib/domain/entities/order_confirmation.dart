class OrderConfirmation {
  final String orderId;
  final String orderNumber;
  final String legacyOrderId;
  final String softlandId;

  OrderConfirmation({
    required this.orderId,
    required this.orderNumber,
    required this.legacyOrderId,
    required this.softlandId,
  });
}
