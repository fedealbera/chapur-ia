import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/error/failures.dart';
import '../../core/constants/constants.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/remote/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login(email, password);
      
      final token = response['token'];
      final userModel = UserModel.fromJson(response['user']);

      // Persist token and user data
      await secureStorage.write(key: AppConstants.tokenKey, value: token);
      await secureStorage.write(
        key: AppConstants.userKey, 
        value: jsonEncode(userModel.toJson()),
      );

      return Right(userModel);
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        final data = e.response?.data as Map;
        if (data.containsKey('error')) {
          return Left(AuthFailure(data['error'].toString()));
        }
      }
      return Left(AuthFailure(e.message ?? 'Error de conexión'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<void> logout() async {
    await secureStorage.delete(key: AppConstants.tokenKey);
    await secureStorage.delete(key: AppConstants.userKey);
  }

  @override
  Future<Either<Failure, User?>> getAuthenticatedUser() async {
    try {
      final userData = await secureStorage.read(key: AppConstants.userKey);
      if (userData != null) {
        return Right(UserModel.fromJson(jsonDecode(userData)));
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
