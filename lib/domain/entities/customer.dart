import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String accountNumber;
  final String name;
  final String cuit;
  final String address;
  final String city;
  final String? province;
  final String? postalCode;
  final String priceListCode;
  final String sellerCode;
  final String? sellerName;
  final String condicionIva;
  final String? phone;
  final double? creditLimit;
  final double? currentBalance;

  const Customer({
    required this.accountNumber,
    required this.name,
    required this.cuit,
    required this.address,
    required this.city,
    this.province,
    this.postalCode,
    required this.priceListCode,
    required this.sellerCode,
    this.sellerName,
    required this.condicionIva,
    this.phone,
    this.creditLimit,
    this.currentBalance,
  });

  @override
  List<Object?> get props => [
        accountNumber,
        name,
        cuit,
        address,
        city,
        province,
        postalCode,
        priceListCode,
        sellerCode,
        sellerName,
        condicionIva,
        phone,
        creditLimit,
        currentBalance,
      ];
}
