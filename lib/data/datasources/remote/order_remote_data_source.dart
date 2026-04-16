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
    final Map<String, dynamic> queryParams = {};
    if (accountNumber != null) {
      queryParams['accountNumber'] = accountNumber;
    }

    final response = await dio.get('/orders', queryParameters: queryParams);

    if (response.statusCode == 200) {
      final List<dynamic> ordersList = response.data;
      return ordersList.map((json) => OrderModel.fromJson(json)).toList();
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  @override
  Future<OrderModel> getOrderDetail(String id) async {
    final response = await dio.get('/orders/$id');

    if (response.statusCode == 200) {
      return OrderModel.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
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
    final response = await dio.post(
      '/orders',
      data: {
        'deliveryAddress': deliveryAddress,
        'deliveryContact': deliveryContact,
        'deliveryPhone': deliveryPhone,
        'notes': notes,
        'estimatedDeliveryDate': estimatedDeliveryDate,
      },
    );

    if (response.statusCode == 200) {
      return response.data['orderId'];
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
