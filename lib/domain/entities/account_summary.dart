import 'package:equatable/equatable.dart';
import 'account_movement.dart';

class AccountSummary extends Equatable {
  final String accountNumber;
  final String customerName;
  final DateTime fechaDesde;
  final DateTime fechaHasta;
  final bool soloPendientes;
  final List<AccountMovement> movements;

  const AccountSummary({
    required this.accountNumber,
    required this.customerName,
    required this.fechaDesde,
    required this.fechaHasta,
    required this.soloPendientes,
    required this.movements,
  });

  double get totalDebe => movements.fold(0, (sum, item) => sum + item.debeN);
  double get totalHaber => movements.fold(0, (sum, item) => sum + item.haberN);
  double get totalSaldo => movements.isNotEmpty ? movements.last.saldoN : 0;

  @override
  List<Object?> get props => [
        accountNumber,
        customerName,
        fechaDesde,
        fechaHasta,
        soloPendientes,
        movements,
      ];
}
