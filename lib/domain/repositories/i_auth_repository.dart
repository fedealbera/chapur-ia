import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../core/error/failures.dart';

abstract class IAuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<Either<Failure, User?>> getAuthenticatedUser();
}
