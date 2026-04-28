import 'package:dio/dio.dart';
import '../../models/account_model.dart';

abstract class IAccountRemoteDataSource {
  Future<AccountSummaryModel> getAccountSummary({
    required String accountNumber,
    required DateTime fechaDesde,
    required DateTime fechaHasta,
    int soloPendientes = 0,
  });

  Future<Map<String, dynamic>> getDocumentDetail(String documentCode, int documentNumber);
}

class AccountRemoteDataSourceImpl implements IAccountRemoteDataSource {
  final Dio dio;

  AccountRemoteDataSourceImpl({required this.dio});

  @override
  Future<AccountSummaryModel> getAccountSummary({
    required String accountNumber,
    required DateTime fechaDesde,
    required DateTime fechaHasta,
    int soloPendientes = 0,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return AccountSummaryModel.fromJson({
      'accountNumber': accountNumber,
      'customerName': 'Cliente de Prueba 1',
      'fechaDesde': fechaDesde.toIso8601String(),
      'fechaHasta': fechaHasta.toIso8601String(),
      'totalDebe': 150000.0,
      'totalHaber': 50000.0,
      'saldoFinal': 100000.0,
      'items': [
        {
          'fecha': DateTime.now().toIso8601String(),
          'documentCode': 'FC',
          'documentNumber': 1001,
          'puntoVenta': '0001',
          'descripcion': 'Factura A',
          'debe': 10000.0,
          'haber': 0.0,
          'saldo': 100000.0,
          'estado': 'Pendiente',
        },
        {
          'fecha': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'documentCode': 'RC',
          'documentNumber': 5001,
          'puntoVenta': '0001',
          'descripcion': 'Recibo',
          'debe': 0.0,
          'haber': 5000.0,
          'saldo': 90000.0,
          'estado': 'Aplicado',
        }
      ]
    });
  }

  @override
  Future<Map<String, dynamic>> getDocumentDetail(String documentCode, int documentNumber) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'documentCode': documentCode,
      'documentNumber': documentNumber,
      'fecha': DateTime.now().toIso8601String(),
      'puntoVenta': '0001',
      'total': 10000.0,
      'items': [
        {
          'description': 'Laptop Dell Latitude',
          'quantity': 1,
          'unitPrice': 10000.0,
          'subtotal': 10000.0,
        }
      ],
    };
  }
}
