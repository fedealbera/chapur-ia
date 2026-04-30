import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../entities/account_summary.dart';

abstract class IAccountRepository {
  Future<Either<Failure, AccountSummary>> getAccountSummary({
    required String accountNumber,
    required DateTime startDate,
    required DateTime endDate,
    int soloPendientes = 0,
  });
}
