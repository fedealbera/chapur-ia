import 'package:dio/dio.dart';
import 'package:chapur_ia/data/models/cart_model.dart';

abstract class ICartRemoteDataSource {
  Future<CartModel> getCart();
  Future<void> addToCart(String articleCode, int quantity);
  Future<void> removeFromCart(String articleCode);
  Future<void> clearCart();
}

class CartRemoteDataSourceImpl implements ICartRemoteDataSource {
  final Dio dio;

  CartRemoteDataSourceImpl({required this.dio});

  @override
  Future<CartModel> getCart() async {
    try {
      final response = await dio.get('/cart');
      return CartModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addToCart(String articleCode, int quantity) async {
    try {
      await dio.post(
        '/cart/items',
        data: {
          'articleCode': articleCode,
          'quantity': quantity,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeFromCart(String articleCode) async {
    try {
      await dio.delete('/cart/items/$articleCode');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await dio.delete('/cart');
    } catch (e) {
      rethrow;
    }
  }
}
