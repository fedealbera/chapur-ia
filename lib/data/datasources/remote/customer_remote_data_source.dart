import 'package:dio/dio.dart';
import '../../models/customer_model.dart';

abstract class ICustomerRemoteDataSource {
  Future<Map<String, dynamic>> searchCustomers({
    required String term,
    int page = 1,
    int pageSize = 15,
  });

  Future<CustomerModel> getCustomerDetail(String accountNumber);
}

class CustomerRemoteDataSourceImpl implements ICustomerRemoteDataSource {
  final Dio dio;

  CustomerRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> searchCustomers({
    required String term,
    int page = 1,
    int pageSize = 15,
  }) async {
    final response = await dio.get(
      '/customers/search',
      queryParameters: {
        'term': term,
        'page': page,
        'pageSize': pageSize,
      },
    );

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

  @override
  Future<CustomerModel> getCustomerDetail(String accountNumber) async {
    final response = await dio.get('/customers/$accountNumber');

    if (response.statusCode == 200) {
      return CustomerModel.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
