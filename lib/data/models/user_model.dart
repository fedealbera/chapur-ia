import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    super.customerAccountNumber,
    super.customerName,
    super.priceListCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      customerAccountNumber: json['customerAccountNumber'],
      customerName: json['customerName'],
      priceListCode: json['priceListCode'],
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
    };
  }
}
