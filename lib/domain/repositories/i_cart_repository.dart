import 'package:dartz/dartz.dart';
import 'package:chapur_ia/core/error/failures.dart';
import 'package:chapur_ia/data/models/cart_model.dart';

abstract class ICartRepository {
  Future<Either<Failure, CartModel>> getCart();
  Future<Either<Failure, void>> addToCart(String articleCode, int quantity);
  Future<Either<Failure, void>> removeFromCart(String articleCode);
  Future<Either<Failure, void>> clearCart();
}
