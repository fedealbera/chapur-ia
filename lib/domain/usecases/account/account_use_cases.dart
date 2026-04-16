import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/i_account_repository.dart';

class GetAccountSummaryUseCase {
  final IAccountRepository repository;

  GetAccountSummaryUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> execute({
    required String accountNumber,
    required DateTime fechaDesde,
    required DateTime fechaHasta,
    int soloPendientes = 0,
  }) {
    return repository.getAccountSummary(
      accountNumber: accountNumber,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      soloPendientes: soloPendientes,
    );
  }
}

class GetDocumentDetailUseCase {
  final IAccountRepository repository;

  GetDocumentDetailUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> execute({
    required String documentCode,
    required int documentNumber,
  }) {
    return repository.getDocumentDetail(
      documentCode: documentCode,
      documentNumber: documentNumber,
    );
  }
}
