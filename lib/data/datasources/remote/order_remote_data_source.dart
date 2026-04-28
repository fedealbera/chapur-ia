import 'package:dio/dio.dart';
import '../../models/order_model.dart';

abstract class IOrderRemoteDataSource {
  Future<List<OrderModel>> getOrders({String? accountNumber});
  Future<OrderModel> getOrderDetail(String id);
  Future<String> createOrder({
    required String deliveryAddress,
    required String deliveryContact,
    required String deliveryPhone,
    String? notes,
    String? estimatedDeliveryDate,
  });
}

class OrderRemoteDataSourceImpl implements IOrderRemoteDataSource {
  final Dio dio;

  OrderRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<OrderModel>> getOrders({String? accountNumber}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (accountNumber != null) {
        queryParams['accountNumber'] = accountNumber;
      }
      final response = await dio.get('/orders', queryParameters: queryParams);
      return (response.data as List).map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OrderModel> getOrderDetail(String id) async {
    try {
      final response = await dio.get('/orders/$id');
      return OrderModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> createOrder({
    required String deliveryAddress,
    required String deliveryContact,
    required String deliveryPhone,
    String? notes,
    String? estimatedDeliveryDate,
  }) async {
    try {
      final data = <String, dynamic>{
        'deliveryAddress': deliveryAddress,
        'deliveryContact': deliveryContact,
        'deliveryPhone': deliveryPhone,
      };
      if (notes != null) data['notes'] = notes;
      if (estimatedDeliveryDate != null) data['estimatedDeliveryDate'] = estimatedDeliveryDate;

      final response = await dio.post('/orders', data: data);
      return response.data['orderId'] as String;
    } catch (e) {
      rethrow;
    }
  }
}
