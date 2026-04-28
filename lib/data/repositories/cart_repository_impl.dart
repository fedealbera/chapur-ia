import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:chapur_ia/core/error/failures.dart';
import 'package:chapur_ia/domain/repositories/i_cart_repository.dart';
import 'package:chapur_ia/data/datasources/remote/cart_remote_data_source.dart';
import 'package:chapur_ia/data/models/cart_model.dart';

class CartRepositoryImpl implements ICartRepository {
  final ICartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CartModel>> getCart() async {
    try {
      final cart = await remoteDataSource.getCart();
      return Right(cart);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(AuthFailure('Sesión expirada o no autorizada.'));
      }
      return Left(ServerFailure(e.message ?? 'Error al obtener el carrito'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToCart(String articleCode, int quantity) async {
    try {
      await remoteDataSource.addToCart(articleCode, quantity);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Error al agregar al carrito'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String articleCode) async {
    try {
      await remoteDataSource.removeFromCart(articleCode);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Error al eliminar del carrito'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await remoteDataSource.clearCart();
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Error al vaciar el carrito'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
