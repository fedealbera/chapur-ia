import 'package:dio/dio.dart';
import '../../models/customer_model.dart';
import 'mocks/mock_customers.dart';

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
    await Future.delayed(const Duration(seconds: 1));
    
    final filtered = term.isEmpty ? mockCustomers : mockCustomers.where((c) => 
      c['name'].toString().toLowerCase().contains(term.toLowerCase()) || 
      c['accountNumber'].toString().toLowerCase().contains(term.toLowerCase())
    ).toList();

    return {
      'items': filtered,
      'total': filtered.length,
      'page': page,
      'pageSize': pageSize,
    };
  }

  @override
  Future<CustomerModel> getCustomerDetail(String accountNumber) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return CustomerModel.fromJson({
      'accountNumber': accountNumber,
      'name': 'Cliente de Prueba 1 ($accountNumber)',
      'cuit': '20123456789',
      'address': 'Calle Falsa 123',
      'city': 'Córdoba',
      'province': 'Córdoba',
      'postalCode': '5000',
      'priceListCode': '1',
      'sellerCode': 'V001',
      'sellerName': 'Vendedor Demo',
      'condicionIva': 'Responsable Inscripto',
      'creditLimit': 100000.0,
      'currentBalance': 25000.0,
    });
  }
}
