import 'package:dartz/dartz.dart';
import 'package:chapur_ia/core/error/failures.dart';
import 'package:chapur_ia/domain/entities/cart.dart';
import 'package:chapur_ia/domain/entities/cart_item.dart';

abstract class ICartRepository {
  Future<Either<Failure, Cart>> getCart();
  Future<Either<Failure, void>> addItem(CartItem item);
  Future<Either<Failure, void>> clearCart();
}
