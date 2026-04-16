import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/i_account_repository.dart';
import '../datasources/remote/account_remote_data_source.dart';

class AccountRepositoryImpl implements IAccountRepository {
  final IAccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAccountSummary({
    required String accountNumber,
    required DateTime fechaDesde,
    required DateTime fechaHasta,
    int soloPendientes = 0,
  }) async {
    try {
      final summary = await remoteDataSource.getAccountSummary(
        accountNumber: accountNumber,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
        soloPendientes: soloPendientes,
      );
      // We return as Map for flexibility since we defined the interface with Map earlier,
      // but we use the model internally for type safety if needed.
      // Actually, let's just convert it back or ensure it matches the interface intent.
      return Right({
        'accountNumber': summary.accountNumber,
        'customerName': summary.customerName,
        'fechaDesde': summary.fechaDesde,
        'fechaHasta': summary.fechaHasta,
        'totalDebe': summary.totalDebe,
        'totalHaber': summary.totalHaber,
        'saldoFinal': summary.saldoFinal,
        'items': summary.items.map((item) => {
          'fecha': item.fecha,
          'documentCode': item.documentCode,
          'documentNumber': item.documentNumber,
          'puntoVenta': item.puntoVenta,
          'descripcion': item.descripcion,
          'debe': item.debe,
          'haber': item.haber,
          'saldo': item.saldo,
          'estado': item.estado,
          'vencimiento': item.vencimiento,
        }).toList(),
      });
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
}
