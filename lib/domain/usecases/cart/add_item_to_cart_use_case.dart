import 'package:dartz/dartz.dart';
import 'package:chapur_ia/core/error/failures.dart';
import 'package:chapur_ia/domain/entities/cart_item.dart';
import 'package:chapur_ia/domain/repositories/i_cart_repository.dart';

class AddItemToCartUseCase {
  final ICartRepository repository;
  AddItemToCartUseCase({required this.repository});

  Future<Either<Failure, void>> execute(CartItem item) {
    return repository.addItem(item);
  }
}
