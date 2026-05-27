import '../../domain/entities/user.dart';
import '../../domain/entities/exchange_rate.dart';
import 'user_balance_model.dart';
import 'exchange_rate_model.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    super.customerAccountNumber,
    super.customerName,
    super.priceListCode,
    super.balance,
    super.exchangeRate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {ExchangeRate? exchangeRate}) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      customerAccountNumber: json['customerAccountNumber']?.toString(),
      customerName: json['customerName']?.toString(),
      priceListCode: json['priceListCode']?.toString(),
      balance: json['balance'] != null
          ? UserBalanceModel.fromJson(json['balance'])
          : null,
      exchangeRate: exchangeRate ?? (json['exchangeRate'] != null
          ? ExchangeRateModel.fromJson(json['exchangeRate'])
          : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'customerAccountNumber': customerAccountNumber,
      'customerName': customerName,
      'priceListCode': priceListCode,
      'balance': balance != null ? (balance as UserBalanceModel).toJson() : null,
      'exchangeRate': exchangeRate != null ? (exchangeRate as ExchangeRateModel).toJson() : null,
    };
  }
}
