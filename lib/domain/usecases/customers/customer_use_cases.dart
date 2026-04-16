import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/customer.dart';
import '../../repositories/i_customer_repository.dart';

class SearchCustomersUseCase {
  final ICustomerRepository repository;

  SearchCustomersUseCase(this.repository);

  Future<Either<Failure, List<Customer>>> execute({
    required String term,
    int page = 1,
    int pageSize = 15,
  }) {
    return repository.searchCustomers(
      term: term,
      page: page,
      pageSize: pageSize,
    );
  }
}

class GetCustomerDetailUseCase {
  final ICustomerRepository repository;

  GetCustomerDetailUseCase(this.repository);

  Future<Either<Failure, Customer>> execute(String accountNumber) {
    return repository.getCustomerDetail(accountNumber);
  }
}
