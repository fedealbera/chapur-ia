import '../../domain/entities/user_balance.dart';

class UserBalanceModel extends UserBalance {
  const UserBalanceModel({
    required super.empresa,
    required super.accountNumber,
    required super.currency,
    required super.saldoN,
    required super.vencido,
    required super.saldoS,
  });

  factory UserBalanceModel.fromJson(Map<String, dynamic> json) {
    return UserBalanceModel(
      empresa: json['empresa']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'ARS',
      saldoN: (json['saldoN'] as num?)?.toDouble() ?? 0.0,
      vencido: (json['vencido'] as num?)?.toDouble() ?? 0.0,
      saldoS: (json['saldoS'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empresa': empresa,
      'accountNumber': accountNumber,
      'currency': currency,
      'saldoN': saldoN,
      'vencido': vencido,
      'saldoS': saldoS,
    };
  }
}
