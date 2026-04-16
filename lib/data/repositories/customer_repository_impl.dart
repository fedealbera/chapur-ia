import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/i_customer_repository.dart';
import '../datasources/remote/customer_remote_data_source.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements ICustomerRepository {
  final ICustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Customer>>> searchCustomers({
    required String term,
    int page = 1,
    int pageSize = 15,
  }) async {
    try {
      final response = await remoteDataSource.searchCustomers(
        term: term,
        page: page,
        pageSize: pageSize,
      );

      final List<dynamic> itemsJson = response['items'];
      final customers = itemsJson.map((json) => CustomerModel.fromJson(json)).toList();

      return Right(customers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer>> getCustomerDetail(String accountNumber) async {
    try {
      final customer = await remoteDataSource.getCustomerDetail(accountNumber);
      return Right(customer);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
