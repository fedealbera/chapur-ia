import 'package:dio/dio.dart';
import '../../models/account_model.dart';
import 'package:intl/intl.dart';

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
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    
    final response = await dio.get(
      '/cuenta-corriente/resumen',
      queryParameters: {
        'accountNumber': accountNumber,
        'fechaDesde': formatter.format(fechaDesde),
        'fechaHasta': formatter.format(fechaHasta),
        'soloPendientes': soloPendientes,
      },
    );

    if (response.statusCode == 200) {
      return AccountSummaryModel.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getDocumentDetail(String documentCode, int documentNumber) async {
    final response = await dio.get('/cuenta-corriente/comprobante/$documentCode/$documentNumber');

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
