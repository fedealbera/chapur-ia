import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../domain/entities/account_summary.dart';
import '../../domain/repositories/i_account_repository.dart';
import '../datasources/remote/account_remote_data_source.dart';

class AccountRepositoryImpl implements IAccountRepository {
  final IAccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AccountSummary>> getAccountSummary({
    required String accountNumber,
    required DateTime startDate,
    required DateTime endDate,
    int soloPendientes = 0,
  }) async {
    try {
      final summary = await remoteDataSource.getAccountSummary(
        accountNumber: accountNumber,
        startDate: startDate,
        endDate: endDate,
        soloPendientes: soloPendientes,
      );
      return Right(summary);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
