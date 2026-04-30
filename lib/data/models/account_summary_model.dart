import '../../domain/entities/account_summary.dart';
import 'account_movement_model.dart';

class AccountSummaryModel extends AccountSummary {
  const AccountSummaryModel({
    required super.accountNumber,
    required super.customerName,
    required super.fechaDesde,
    required super.fechaHasta,
    required super.soloPendientes,
    required super.movements,
  });

  factory AccountSummaryModel.fromJson(Map<String, dynamic> json) {
    return AccountSummaryModel(
      accountNumber: json['accountNumber'] ?? '',
      customerName: json['customerName'] ?? '',
      fechaDesde: DateTime.parse(json['fechaDesde']),
      fechaHasta: DateTime.parse(json['fechaHasta']),
      soloPendientes: json['soloPendientes'] ?? false,
      movements: (json['rows'] as List)
          .map((row) => AccountMovementModel.fromJson(row))
          .toList(),
    );
  }
}
