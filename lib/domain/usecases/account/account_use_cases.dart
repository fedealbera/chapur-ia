import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/account_summary.dart';
import '../../repositories/i_account_repository.dart';

class GetAccountSummaryUseCase {
  final IAccountRepository repository;

  GetAccountSummaryUseCase(this.repository);

  Future<Either<Failure, AccountSummary>> execute({
    required String accountNumber,
    required DateTime startDate,
    required DateTime endDate,
    int soloPendientes = 0,
  }) {
    return repository.getAccountSummary(
      accountNumber: accountNumber,
      startDate: startDate,
      endDate: endDate,
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

class GetDocumentPdfUseCase {
  final IAccountRepository repository;

  GetDocumentPdfUseCase(this.repository);

  Future<Either<Failure, String>> execute({
    required String documentCode,
    required int documentNumber,
  }) {
    return repository.getDocumentPdfPath(
      documentCode: documentCode,
      documentNumber: documentNumber,
    );
  }
}
