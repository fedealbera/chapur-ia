import 'package:dartz/dartz.dart';
import '../entities/customer.dart';
import '../../core/error/failures.dart';

abstract class ICustomerRepository {
  Future<Either<Failure, List<Customer>>> searchCustomers({
    required String term,
    int page = 1,
    int pageSize = 15,
  });

  Future<Either<Failure, Customer>> getCustomerDetail(String accountNumber);
}
