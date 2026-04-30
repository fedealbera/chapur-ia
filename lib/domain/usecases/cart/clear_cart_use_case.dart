import 'package:dartz/dartz.dart';
import 'package:chapur_ia/core/error/failures.dart';
import 'package:chapur_ia/domain/repositories/i_cart_repository.dart';

class ClearCartUseCase {
  final ICartRepository repository;
  ClearCartUseCase({required this.repository});

  Future<Either<Failure, void>> execute() {
    return repository.clearCart();
  }
}
