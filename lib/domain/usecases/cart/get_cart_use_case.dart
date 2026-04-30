import 'package:dartz/dartz.dart';
import 'package:chapur_ia/core/error/failures.dart';
import 'package:chapur_ia/domain/entities/cart.dart';
import 'package:chapur_ia/domain/repositories/i_cart_repository.dart';

class GetCartUseCase {
  final ICartRepository repository;
  GetCartUseCase({required this.repository});

  Future<Either<Failure, Cart>> execute() {
    return repository.getCart();
  }
}
