import 'package:dio/dio.dart';
import 'package:chapur_ia/data/models/cart_model.dart';
import 'package:chapur_ia/data/models/cart_discounts_model.dart';

abstract class ICartRemoteDataSource {
  Future<CartModel> getCart();
  Future<void> addItem(CartItemModel item);
  Future<void> removeItem(String articleCode);
  Future<void> selectCustomer(String customerAccountNumber);
  Future<void> clearCart();
  Future<CartDiscountsModel?> getDiscounts();
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
      return const CartModel(items: [], subtotal: 0.0, ivaTotal: 0.0, grandTotal: 0.0);
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
  Future<void> removeItem(String articleCode) async {
    try {
      await dio.delete('/cart/items/$articleCode');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> selectCustomer(String customerAccountNumber) async {
    try {
      await dio.post(
        '/cart/select-customer',
        data: {'customerAccountNumber': customerAccountNumber},
      );
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

  @override
  Future<CartDiscountsModel?> getDiscounts() async {
    try {
      final response = await dio.get('/cart/discounts');
      return CartDiscountsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // If it fails or returns 404, we return null or empty discounts
      return null;
    }
  }
}
