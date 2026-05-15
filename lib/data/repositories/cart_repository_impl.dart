import 'package:dartz/dartz.dart';
import 'package:chapur_ia/core/error/failures.dart';
import 'package:chapur_ia/core/error/error_handler.dart';
import 'package:chapur_ia/data/datasources/remote/cart_remote_data_source.dart';
import 'package:chapur_ia/data/models/cart_model.dart';
import 'package:chapur_ia/data/models/cart_discounts_model.dart';
import 'package:chapur_ia/domain/entities/cart.dart';
import 'package:chapur_ia/domain/entities/cart_item.dart';
import 'package:chapur_ia/domain/repositories/i_cart_repository.dart';

class CartRepositoryImpl implements ICartRepository {
  final ICartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Cart>> getCart() async {
    try {
      final cart = await remoteDataSource.getCart();
      return Right(cart);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> addItem(CartItem item) async {
    try {
      final model = CartItemModel(
        articleCode: item.articleCode,
        quantity: item.quantity,
      );
      await remoteDataSource.addItem(model);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeItem(String articleCode) async {
    try {
      await remoteDataSource.removeItem(articleCode);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> selectCustomer(String customerAccountNumber) async {
    try {
      await remoteDataSource.selectCustomer(customerAccountNumber);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await remoteDataSource.clearCart();
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, CartDiscountsModel?>> getDiscounts() async {
    try {
      final discounts = await remoteDataSource.getDiscounts();
      return Right(discounts);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
