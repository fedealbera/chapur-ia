import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/i_cart_repository.dart';

class SelectCartCustomerUseCase {
  final ICartRepository repository;

  SelectCartCustomerUseCase(this.repository);

  Future<Either<Failure, void>> execute(String customerAccountNumber) {
    return repository.selectCustomer(customerAccountNumber);
  }
}
