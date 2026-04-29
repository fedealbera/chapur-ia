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
      accountNumber: json['accountNumber']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      cuit: json['cuit']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      province: json['province']?.toString(),
      postalCode: json['postalCode']?.toString(),
      priceListCode: json['priceListCode']?.toString() ?? '',
      sellerCode: json['sellerCode']?.toString() ?? '',
      sellerName: json['sellerName']?.toString(),
      condicionIva: json['condicionIva']?.toString() ?? '',
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
