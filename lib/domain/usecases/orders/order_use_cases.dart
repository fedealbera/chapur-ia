import 'package:dartz/dartz.dart' hide Order;
import 'package:chapur_ia/core/error/failures.dart';
import 'package:chapur_ia/domain/entities/order.dart';
import 'package:chapur_ia/domain/repositories/i_order_repository.dart';

class GetOrdersUseCase {
  final IOrderRepository repository;

  GetOrdersUseCase(this.repository);

  Future<Either<Failure, List<Order>>> execute({String? accountNumber}) {
    return repository.getOrders(accountNumber: accountNumber);
  }
}

class GetOrderDetailUseCase {
  final IOrderRepository repository;

  GetOrderDetailUseCase(this.repository);

  Future<Either<Failure, Order>> execute(String id) {
    return repository.getOrderDetail(id);
  }
}

class CreateOrderUseCase {
  final IOrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Either<Failure, String>> execute({
    required String deliveryAddress,
    required String deliveryContact,
    required String deliveryPhone,
    String? notes,
    String? estimatedDeliveryDate,
  }) {
    return repository.createOrder(
      deliveryAddress: deliveryAddress,
      deliveryContact: deliveryContact,
      deliveryPhone: deliveryPhone,
      notes: notes,
      estimatedDeliveryDate: estimatedDeliveryDate,
    );
  }
}
