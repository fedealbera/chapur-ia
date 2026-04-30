import 'package:dio/dio.dart';
import '../../models/account_summary_model.dart';

abstract class IAccountRemoteDataSource {
  Future<AccountSummaryModel> getAccountSummary({
    required String accountNumber,
    required DateTime startDate,
    required DateTime endDate,
    int soloPendientes = 0,
  });

  Future<Map<String, dynamic>> getDocumentDetail(String documentCode, int documentNumber);
  
  Future<List<int>> getDocumentPdf(String documentCode, int documentNumber);
}

class AccountRemoteDataSourceImpl implements IAccountRemoteDataSource {
  final Dio dio;

  AccountRemoteDataSourceImpl({required this.dio});

  @override
  Future<AccountSummaryModel> getAccountSummary({
    required String accountNumber,
    required DateTime startDate,
    required DateTime endDate,
    int soloPendientes = 0,
  }) async {
    try {
      final String formattedStartDate = "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}T00:00:00";
      final String formattedEndDate = "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}T00:00:00";

      final response = await dio.get(
        '/cuenta-corriente/resumen',
        queryParameters: {
          'accountNumber': accountNumber.trim(),
          'fechaDesde': formattedStartDate,
          'fechaHasta': formattedEndDate,
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

  @override
  Future<List<int>> getDocumentPdf(String documentCode, int documentNumber) async {
    try {
      final response = await dio.get(
        '/cuenta-corriente/comprobante/$documentCode/$documentNumber/pdf',
        queryParameters: {'download': true},
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data as List<int>;
    } catch (e) {
      rethrow;
    }
  }
}
