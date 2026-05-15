import 'package:chapur_ia/domain/entities/delivery_defaults.dart';

class DeliveryDefaultsModel extends DeliveryDefaults {
  const DeliveryDefaultsModel({
    required super.deliveryAddress,
    required super.deliveryPostalCode,
    super.deliveryContact,
    super.deliveryPhone,
  });

  factory DeliveryDefaultsModel.fromJson(Map<String, dynamic> json) {
    return DeliveryDefaultsModel(
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      deliveryPostalCode: json['deliveryPostalCode']?.toString() ?? '',
      deliveryContact: json['deliveryContact']?.toString(),
      deliveryPhone: json['deliveryPhone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deliveryAddress': deliveryAddress,
      'deliveryPostalCode': deliveryPostalCode,
      'deliveryContact': deliveryContact,
      'deliveryPhone': deliveryPhone,
    };
  }
}
