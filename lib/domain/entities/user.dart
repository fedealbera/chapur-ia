import 'package:equatable/equatable.dart';
import 'user_balance.dart';
import 'exchange_rate.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? customerAccountNumber;
  final String? customerName;
  final String? priceListCode;
  final UserBalance? balance;
  final ExchangeRate? exchangeRate;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.customerAccountNumber,
    this.customerName,
    this.priceListCode,
    this.balance,
    this.exchangeRate,
  });

  bool get isAdmin => role == 'Admin';
  bool get isSalesperson => role == 'Salesperson';
  bool get isCustomer => role == 'Customer';
  bool get isGuest => role == 'Guest';

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        role,
        customerAccountNumber,
        customerName,
        priceListCode,
        balance,
        exchangeRate,
      ];
}
