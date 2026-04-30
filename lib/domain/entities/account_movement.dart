import 'package:equatable/equatable.dart';

class AccountMovement extends Equatable {
  final String empresa;
  final String nroCta;
  final String codigoCompro;
  final int numeroCompro;
  final String contrato;
  final DateTime fecha;
  final DateTime vto;
  final String razonSocial;
  final String moneda;
  final double debeN;
  final double haberN;
  final double saldoN;
  final double debeS;
  final double haberS;
  final double saldoS;
  final int pendiente;
  final String comprobantePDF;

  const AccountMovement({
    required this.empresa,
    required this.nroCta,
    required this.codigoCompro,
    required this.numeroCompro,
    required this.contrato,
    required this.fecha,
    required this.vto,
    required this.razonSocial,
    required this.moneda,
    required this.debeN,
    required this.haberN,
    required this.saldoN,
    required this.debeS,
    required this.haberS,
    required this.saldoS,
    required this.pendiente,
    required this.comprobantePDF,
  });

  @override
  List<Object?> get props => [
        empresa,
        nroCta,
        codigoCompro,
        numeroCompro,
        contrato,
        fecha,
        vto,
        razonSocial,
        moneda,
        debeN,
        haberN,
        saldoN,
        debeS,
        haberS,
        saldoS,
        pendiente,
        comprobantePDF,
      ];
}
