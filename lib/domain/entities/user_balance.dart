import 'package:equatable/equatable.dart';

class UserBalance extends Equatable {
  final String empresa;
  final String accountNumber;
  final String currency;
  final double saldoN;
  final double vencido;
  final double saldoS;

  const UserBalance({
    required this.empresa,
    required this.accountNumber,
    required this.currency,
    required this.saldoN,
    required this.vencido,
    required this.saldoS,
  });

  @override
  List<Object?> get props => [
        empresa,
        accountNumber,
        currency,
        saldoN,
        vencido,
        saldoS,
      ];
}
