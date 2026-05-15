import 'package:dartz/dartz.dart';
import 'package:chapur_ia/core/error/failures.dart';
import 'package:chapur_ia/domain/entities/cart_discounts.dart';
import 'package:chapur_ia/domain/repositories/i_cart_repository.dart';

class GetCartDiscountsUseCase {
  final ICartRepository repository;

  GetCartDiscountsUseCase(this.repository);

  Future<Either<Failure, CartDiscounts?>> execute() async {
    return await repository.getDiscounts();
  }
}
