import 'package:dio/dio.dart';
import 'package:chapur_ia/data/models/cart_model.dart';

abstract class ICartRemoteDataSource {
  Future<CartModel> getCart();
  Future<void> addItem(CartItemModel item);
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
      // If the cart doesn't exist yet, we might get a 404 or empty response.
      // Based on user info, GET /api/cart creates it if not exists or just returns OK.
      // We'll return an empty cart if it fails or if data is missing.
      return const CartModel(items: [], totalAmount: 0.0);
    }
  }

  @override
  Future<void> addItem(CartItemModel item) async {
    try {
      await dio.post('/cart/items', data: item.toJson());
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
