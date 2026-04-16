import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class IAccountRepository {
  Future<Either<Failure, Map<String, dynamic>>> getAccountSummary({
    required String accountNumber,
    required DateTime fechaDesde,
    required DateTime fechaHasta,
    int soloPendientes = 0,
  });

  Future<Either<Failure, Map<String, dynamic>>> getDocumentDetail({
    required String documentCode,
    required int documentNumber,
  });
}
