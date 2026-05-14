import '../../domain/entities/user.dart';
import 'user_balance_model.dart';

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
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
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
    };
  }
}
