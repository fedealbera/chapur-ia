import 'package:equatable/equatable.dart';

class AccountItemModel extends Equatable {
  final String fecha;
  final String documentCode;
  final int documentNumber;
  final String puntoVenta;
  final String descripcion;
  final double debe;
  final double haber;
  final double saldo;
  final String estado;
  final String? vencimiento;

  const AccountItemModel({
    required this.fecha,
    required this.documentCode,
    required this.documentNumber,
    required this.puntoVenta,
    required this.descripcion,
    required this.debe,
    required this.haber,
    required this.saldo,
    required this.estado,
    this.vencimiento,
  });

  factory AccountItemModel.fromJson(Map<String, dynamic> json) {
    return AccountItemModel(
      fecha: json['fecha'],
      documentCode: json['documentCode'],
      documentNumber: json['documentNumber'],
      puntoVenta: json['puntoVenta'],
      descripcion: json['descripcion'],
      debe: (json['debe'] as num).toDouble(),
      haber: (json['haber'] as num).toDouble(),
      saldo: (json['saldo'] as num).toDouble(),
      estado: json['estado'],
      vencimiento: json['vencimiento'],
    );
  }

  @override
  List<Object?> get props => [
        fecha,
        documentCode,
        documentNumber,
        puntoVenta,
        descripcion,
        debe,
        haber,
        saldo,
        estado,
        vencimiento,
      ];
}

class AccountSummaryModel extends Equatable {
  final String accountNumber;
  final String customerName;
  final String fechaDesde;
  final String fechaHasta;
  final double totalDebe;
  final double totalHaber;
  final double saldoFinal;
  final List<AccountItemModel> items;

  const AccountSummaryModel({
    required this.accountNumber,
    required this.customerName,
    required this.fechaDesde,
    required this.fechaHasta,
    required this.totalDebe,
    required this.totalHaber,
    required this.saldoFinal,
    required this.items,
  });

  factory AccountSummaryModel.fromJson(Map<String, dynamic> json) {
    return AccountSummaryModel(
      accountNumber: json['accountNumber'],
      customerName: json['customerName'],
      fechaDesde: json['fechaDesde'],
      fechaHasta: json['fechaHasta'],
      totalDebe: (json['totalDebe'] as num).toDouble(),
      totalHaber: (json['totalHaber'] as num).toDouble(),
      saldoFinal: (json['saldoFinal'] as num).toDouble(),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => AccountItemModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        accountNumber,
        customerName,
        fechaDesde,
        fechaHasta,
        totalDebe,
        totalHaber,
        saldoFinal,
        items,
      ];
}
