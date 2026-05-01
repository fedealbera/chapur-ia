import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:chapur_ia/core/error/failures.dart';
import 'package:chapur_ia/domain/entities/order.dart';
import 'package:chapur_ia/domain/repositories/i_order_repository.dart';
import 'package:chapur_ia/data/datasources/remote/order_remote_data_source.dart';

class OrderRepositoryImpl implements IOrderRepository {
  final IOrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Order>>> getOrders({String? accountNumber}) async {
    try {
      final orders = await remoteDataSource.getOrders(accountNumber: accountNumber);
      return Right(orders);
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
          return const Left(ServerFailure('El servidor tardó demasiado en responder. Reintente en unos momentos.'));
        }
        return Left(ServerFailure('Error de red: ${e.message}'));
      } else if (e is FormatException) {
        return Left(ServerFailure(e.message));
      }
      return const Left(ServerFailure('Ocurrió un error inesperado al cargar los pedidos.'));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderDetail(String id) async {
    try {
      final order = await remoteDataSource.getOrderDetail(id);
      return Right(order);
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
          return const Left(ServerFailure('El servidor tardó demasiado en responder. Reintente en unos momentos.'));
        }
        return Left(ServerFailure('Error de red: ${e.message}'));
      } else if (e is FormatException) {
        return Left(ServerFailure(e.message));
      }
      return const Left(ServerFailure('Ocurrió un error inesperado al cargar el detalle del pedido.'));
    }
  }

  @override
  Future<Either<Failure, String>> createOrder({
    required String deliveryAddress,
    required String deliveryContact,
    required String deliveryPhone,
    String? notes,
    String? estimatedDeliveryDate,
  }) async {
    try {
      final orderId = await remoteDataSource.createOrder(
        deliveryAddress: deliveryAddress,
        deliveryContact: deliveryContact,
        deliveryPhone: deliveryPhone,
        notes: notes,
        estimatedDeliveryDate: estimatedDeliveryDate,
      );
      return Right(orderId);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure('Error al crear el pedido: ${e.message}'));
      }
      return const Left(ServerFailure('Ocurrió un error inesperado al crear el pedido.'));
    }
  }
}
