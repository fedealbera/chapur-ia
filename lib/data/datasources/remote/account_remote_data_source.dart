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
    try {
      final response = await dio.get(
        '/cuenta-corriente/resumen',
        queryParameters: {
          'accountNumber': accountNumber,
          'fechaDesde': fechaDesde.toIso8601String(),
          'fechaHasta': fechaHasta.toIso8601String(),
          'soloPendientes': soloPendientes,
        },
      );
      return AccountSummaryModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getDocumentDetail(String documentCode, int documentNumber) async {
    try {
      final response = await dio.get('/cuenta-corriente/comprobante/$documentCode/$documentNumber');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
