import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/error/failures.dart';
import '../../core/error/error_handler.dart';
import '../../core/constants/constants.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_cart_repository.dart';
import '../datasources/remote/auth_remote_data_source.dart';
import '../models/user_model.dart';
import '../models/exchange_rate_model.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;
  final ICartRepository cartRepository;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
    required this.cartRepository,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login(email, password);
      
      final token = response['token'];
      final exchangeRateJson = response['exchangeRate'];
      final exchangeRate = exchangeRateJson != null
          ? ExchangeRateModel.fromJson(exchangeRateJson)
          : null;
      final userModel = UserModel.fromJson(response['user'], exchangeRate: exchangeRate);

      // Persist token and user data
      await secureStorage.write(key: AppConstants.tokenKey, value: token);
      await secureStorage.write(
        key: AppConstants.userKey, 
        value: jsonEncode(userModel.toJson()),
      );
      
      // Save credentials for fast/automatic login
      await secureStorage.write(key: AppConstants.savedEmailKey, value: email);
      await secureStorage.write(key: AppConstants.savedPasswordKey, value: password);

      return Right(userModel);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<void> logout() async {
    // Call DELETE /api/cart before clearing local session.
    // Silently ignore errors so logout always completes.
    try {
      final token = await secureStorage.read(key: AppConstants.tokenKey);
      if (token != null && token != 'GUEST_MODE') {
        await cartRepository.clearCart();
      }
    } catch (_) {}
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
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, User>> loginAsGuest() async {
    try {
      const guestModel = UserModel(
        id: 'guest',
        email: '',
        name: 'Invitado',
        role: 'Guest',
      );

      await secureStorage.write(key: AppConstants.tokenKey, value: 'GUEST_MODE');
      await secureStorage.write(
        key: AppConstants.userKey, 
        value: jsonEncode(guestModel.toJson()),
      );

      return const Right(guestModel);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>?>> getSavedCredentials() async {
    try {
      final email = await secureStorage.read(key: AppConstants.savedEmailKey);
      final password = await secureStorage.read(key: AppConstants.savedPasswordKey);
      if (email != null && password != null) {
        return Right({
          'email': email,
          'password': password,
        });
      }
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> clearSavedCredentials() async {
    try {
      await secureStorage.delete(key: AppConstants.savedEmailKey);
      await secureStorage.delete(key: AppConstants.savedPasswordKey);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
