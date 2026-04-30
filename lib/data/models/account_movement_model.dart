import '../../domain/entities/account_movement.dart';

class AccountMovementModel extends AccountMovement {
  const AccountMovementModel({
    required super.empresa,
    required super.nroCta,
    required super.codigoCompro,
    required super.numeroCompro,
    required super.contrato,
    required super.fecha,
    required super.vto,
    required super.razonSocial,
    required super.moneda,
    required super.debeN,
    required super.haberN,
    required super.saldoN,
    required super.debeS,
    required super.haberS,
    required super.saldoS,
    required super.pendiente,
    required super.comprobantePDF,
  });

  factory AccountMovementModel.fromJson(Map<String, dynamic> json) {
    return AccountMovementModel(
      empresa: json['empresa'] ?? '',
      nroCta: json['nroCta']?.toString().trim() ?? '',
      codigoCompro: json['codigoCompro'] ?? '',
      numeroCompro: (json['numeroCompro'] as num?)?.toInt() ?? 0,
      contrato: json['contrato'] ?? '',
      fecha: DateTime.parse(json['fecha']),
      vto: DateTime.parse(json['vto']),
      razonSocial: json['razonSocial'] ?? '',
      moneda: json['moneda'] ?? '',
      debeN: (json['debeN'] as num?)?.toDouble() ?? 0.0,
      haberN: (json['haberN'] as num?)?.toDouble() ?? 0.0,
      saldoN: (json['saldoN'] as num?)?.toDouble() ?? 0.0,
      debeS: (json['debeS'] as num?)?.toDouble() ?? 0.0,
      haberS: (json['haberS'] as num?)?.toDouble() ?? 0.0,
      saldoS: (json['saldoS'] as num?)?.toDouble() ?? 0.0,
      pendiente: (json['pendiente'] as num?)?.toInt() ?? 0,
      comprobantePDF: json['comprobantePDF'] ?? '',
    );
  }
}
