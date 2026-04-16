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
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderDetail(String id) async {
    try {
      final order = await remoteDataSource.getOrderDetail(id);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
      return Left(ServerFailure(e.toString()));
    }
  }
}
