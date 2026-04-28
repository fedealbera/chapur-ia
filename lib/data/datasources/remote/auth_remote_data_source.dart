import 'package:dio/dio.dart';

abstract class IAuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // MOCK DATA
    if (email == 'error@test.com') {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
          statusMessage: 'Credenciales inválidas',
        )
      );
    }

    return {
      'token': 'mock_token_12345',
      'user': {
        'id': '1',
        'email': email,
        'name': 'Usuario de Prueba',
        'role': 'Salesperson',
        'customerAccountNumber': 'CU001',
        'customerName': 'Cliente de Prueba 1',
        'priceListCode': '1',
      }
    };
  }
}
