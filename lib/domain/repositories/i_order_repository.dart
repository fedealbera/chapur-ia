import 'package:dartz/dartz.dart' hide Order;
import 'package:chapur_ia/domain/entities/order.dart';
import 'package:chapur_ia/core/error/failures.dart';

abstract class IOrderRepository {
  Future<Either<Failure, List<Order>>> getOrders({String? accountNumber});

  Future<Either<Failure, Order>> getOrderDetail(String id);

  Future<Either<Failure, String>> createOrder({
    required String deliveryAddress,
    required String deliveryContact,
    required String deliveryPhone,
    String? notes,
    String? estimatedDeliveryDate,
  });
}
