import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../domain/entities/account_summary.dart';
import '../../domain/repositories/i_account_repository.dart';
import '../datasources/remote/account_remote_data_source.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';

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

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDocumentDetail({
    required String documentCode,
    required int documentNumber,
  }) async {
    try {
      final detail = await remoteDataSource.getDocumentDetail(documentCode, documentNumber);
      return Right(detail);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getDocumentPdfPath({
    required String documentCode,
    required int documentNumber,
  }) async {
    try {
      final bytes = await remoteDataSource.getDocumentPdf(documentCode, documentNumber);
      final tempDir = await getTemporaryDirectory();
      final fileName = '${documentCode}_$documentNumber.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return Right(file.path);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
