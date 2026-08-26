import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chapur_ia/core/constants/constants.dart';
import 'package:chapur_ia/core/network/auth_event_bus.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;

  AuthInterceptor({required this.secureStorage});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // No inyectar token en el endpoint de login
    if (!options.path.contains('/auth/login')) {
      final token = await secureStorage.read(key: AppConstants.tokenKey);
      
      if (token == 'GUEST_MODE') {
        if (options.path.contains('/products')) {
          options.path = options.path.replaceFirst(RegExp(r'/products(/search)?'), '/products/guest');
          
          if (options.queryParameters.containsKey('q')) {
            options.queryParameters['search'] = options.queryParameters.remove('q');
          }
          options.headers['X-Api-Key'] = 'tmc_izhRjMSY41kg0jNBTcouLynUbNISku8i';
        }
      } else if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/auth/login')) {
      final token = await secureStorage.read(key: AppConstants.tokenKey);
      if (token != null) {
        // Clear current session tokens
        await secureStorage.delete(key: AppConstants.tokenKey);
        await secureStorage.delete(key: AppConstants.userKey);

        // Notify the application about session expiration
        AuthEventBus.instance.notifySessionExpired();
      }
    }
    return handler.next(err);
  }
}
