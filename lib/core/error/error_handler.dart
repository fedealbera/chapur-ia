import 'package:dio/dio.dart';
import 'failures.dart';

class ErrorHandler {
  static Failure handleException(dynamic exception) {
    if (exception is DioException) {
      return _handleDioException(exception);
    }
    return ServerFailure(exception.toString());
  }

  static Failure _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerFailure('Tiempo de espera agotado. Por favor, intente de nuevo.');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        
        if (data is Map && data.containsKey('message')) {
          return ServerFailure(data['message'].toString());
        }
        if (data is Map && data.containsKey('error')) {
          return ServerFailure(data['error'].toString());
        }

        switch (statusCode) {
          case 400:
            return const ServerFailure('Solicitud incorrecta.');
          case 401:
            return const AuthFailure('Sesión expirada o no autorizada.');
          case 403:
            return const AuthFailure('No tiene permisos para realizar esta acción.');
          case 404:
            return const ServerFailure('Recurso no encontrado.');
          case 429:
            return const ServerFailure('Demasiadas solicitudes. Por favor, espere un momento.');
          case 500:
            return const ServerFailure('Error interno del servidor. Por favor, intente más tarde.');
          case 503:
            return const ServerFailure('Servicio no disponible actualmente.');
          default:
            return ServerFailure('Error del servidor ($statusCode).');
        }
      
      case DioExceptionType.cancel:
        return const ServerFailure('Solicitud cancelada.');
      
      case DioExceptionType.connectionError:
        return const ServerFailure('Error de conexión. Verifique su internet.');
      
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return const ServerFailure('Sin conexión a internet.');
        }
        return const ServerFailure('Ocurrió un error inesperado.');
      
      default:
        return const ServerFailure('Ocurrió un error inesperado.');
    }
  }
}
