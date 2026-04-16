import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.accountNumber,
    required super.name,
    required super.cuit,
    required super.address,
    required super.city,
    super.province,
    super.postalCode,
    required super.priceListCode,
    required super.sellerCode,
    super.sellerName,
    required super.condicionIva,
    super.creditLimit,
    super.currentBalance,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      accountNumber: json['accountNumber'],
      name: json['name'],
      cuit: json['cuit'],
      address: json['address'],
      city: json['city'],
      province: json['province'],
      postalCode: json['postalCode'],
      priceListCode: json['priceListCode'],
      sellerCode: json['sellerCode'],
      sellerName: json['sellerName'],
      condicionIva: json['condicionIva'],
      creditLimit: (json['creditLimit'] as num?)?.toDouble(),
      currentBalance: (json['currentBalance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'name': name,
      'cuit': cuit,
      'address': address,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'priceListCode': priceListCode,
      'sellerCode': sellerCode,
      'sellerName': sellerName,
      'condicionIva': condicionIva,
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
    };
  }
}
