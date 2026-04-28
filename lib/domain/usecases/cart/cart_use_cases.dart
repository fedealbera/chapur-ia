import 'package:dartz/dartz.dart';
import 'package:chapur_ia/core/error/failures.dart';
import 'package:chapur_ia/data/models/cart_model.dart';
import 'package:chapur_ia/domain/repositories/i_cart_repository.dart';

class GetCartUseCase {
  final ICartRepository repository;
  GetCartUseCase(this.repository);

  Future<Either<Failure, CartModel>> call() {
    return repository.getCart();
  }
}

class AddToCartUseCase {
  final ICartRepository repository;
  AddToCartUseCase(this.repository);

  Future<Either<Failure, void>> call(String articleCode, int quantity) {
    return repository.addToCart(articleCode, quantity);
  }
}

class RemoveFromCartUseCase {
  final ICartRepository repository;
  RemoveFromCartUseCase(this.repository);

  Future<Either<Failure, void>> call(String articleCode) {
    return repository.removeFromCart(articleCode);
  }
}

class ClearCartUseCase {
  final ICartRepository repository;
  ClearCartUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.clearCart();
  }
}
