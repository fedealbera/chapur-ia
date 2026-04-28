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
    try {
      final response = await dio.get(
        '/customers/search',
        queryParameters: {
          'term': term,
          'page': page,
          'pageSize': pageSize,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CustomerModel> getCustomerDetail(String accountNumber) async {
    try {
      final response = await dio.get('/customers/$accountNumber');
      return CustomerModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
