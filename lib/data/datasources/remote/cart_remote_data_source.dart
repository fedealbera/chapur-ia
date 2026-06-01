import 'package:dio/dio.dart';
import 'package:chapur_ia/data/models/cart_model.dart';
import 'package:chapur_ia/data/models/cart_discounts_model.dart';
import 'package:chapur_ia/data/models/delivery_defaults_model.dart';

abstract class ICartRemoteDataSource {
  Future<CartModel> getCart();
  Future<void> addItem(CartItemModel item);
  Future<void> removeItem(String articleCode);
  Future<void> selectCustomer(String customerAccountNumber);
  Future<void> clearCart();
  Future<CartDiscountsModel?> getDiscounts();
  Future<DeliveryDefaultsModel?> getDeliveryDefaults();
}

class CartRemoteDataSourceImpl implements ICartRemoteDataSource {
  final Dio dio;
  String? _cachedShippingLabel;
  bool? _cachedShippingFree;

  CartRemoteDataSourceImpl({required this.dio});

  @override
  Future<CartModel> getCart() async {
    try {
      final response = await dio.get('/cart');
      final data = response.data as Map<String, dynamic>;

      final apiShippingLabel = data['shippingLabel']?.toString() ?? data['customer']?['shippingLabel']?.toString();
      final apiShippingFree = (data['shippingFree'] as bool?) ?? (data['customer']?['shippingFree'] as bool?);

      if (apiShippingLabel != null) {
        _cachedShippingLabel = apiShippingLabel;
      }
      if (apiShippingFree != null) {
        _cachedShippingFree = apiShippingFree;
      }

      final cart = CartModel.fromJson(data);
      return cart.copyWith(
        shippingLabel: apiShippingLabel ?? _cachedShippingLabel,
        shippingFree: apiShippingFree ?? _cachedShippingFree,
      );
    } catch (e) {
      // If the cart doesn't exist yet, we might get a 404 or empty response.
      // Based on user info, GET /api/cart creates it if not exists or just returns OK.
      // We'll return an empty cart if it fails or if data is missing.
      return CartModel(
        items: const [],
        subtotal: 0.0,
        ivaTotal: 0.0,
        grandTotal: 0.0,
        shippingLabel: _cachedShippingLabel,
        shippingFree: _cachedShippingFree,
      );
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
      final response = await dio.post(
        '/cart/select-customer',
        data: {'customerAccountNumber': customerAccountNumber},
      );
      final responseData = response.data as Map<String, dynamic>?;
      if (responseData != null && responseData['customer'] != null) {
        final customerData = responseData['customer'] as Map<String, dynamic>;
        _cachedShippingLabel = customerData['shippingLabel']?.toString();
        _cachedShippingFree = customerData['shippingFree'] as bool?;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await dio.delete('/cart');
      _cachedShippingLabel = null;
      _cachedShippingFree = null;
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

  @override
  Future<DeliveryDefaultsModel?> getDeliveryDefaults() async {
    try {
      final response = await dio.get('/cart/delivery-defaults');
      return DeliveryDefaultsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
}
