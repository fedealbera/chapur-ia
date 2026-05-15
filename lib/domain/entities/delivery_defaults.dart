class DeliveryDefaults {
  final String deliveryAddress;
  final String deliveryPostalCode;
  final String? deliveryContact;
  final String? deliveryPhone;

  const DeliveryDefaults({
    required this.deliveryAddress,
    required this.deliveryPostalCode,
    this.deliveryContact,
    this.deliveryPhone,
  });
}
