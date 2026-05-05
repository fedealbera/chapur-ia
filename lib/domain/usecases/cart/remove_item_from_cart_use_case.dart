import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/i_cart_repository.dart';

class RemoveItemFromCartUseCase {
  final ICartRepository repository;

  RemoveItemFromCartUseCase(this.repository);

  Future<Either<Failure, void>> execute(String articleCode) {
    return repository.removeItem(articleCode);
  }
}
