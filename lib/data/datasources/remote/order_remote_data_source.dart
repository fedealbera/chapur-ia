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
    await Future.delayed(const Duration(seconds: 1));
    return [
      OrderModel.fromJson({
        'id': '1',
        'orderNumber': 'ORD-001',
        'legacyOrderId': 'LEG-001',
        'customerAccountNumber': accountNumber ?? 'CU001',
        'customerName': 'Cliente de Prueba 1',
        'date': DateTime.now().toIso8601String(),
        'status': 'Pendiente',
        'total': 1500.00,
        'items': []
      }),
      OrderModel.fromJson({
        'id': '2',
        'orderNumber': 'ORD-002',
        'legacyOrderId': 'LEG-002',
        'customerAccountNumber': accountNumber ?? 'CU001',
        'customerName': 'Cliente de Prueba 1',
        'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'status': 'Entregado',
        'total': 3200.50,
        'items': []
      }),
    ];
  }

  @override
  Future<OrderModel> getOrderDetail(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    return OrderModel.fromJson({
      'id': id,
      'orderNumber': 'ORD-00$id',
      'legacyOrderId': 'LEG-00$id',
      'customerAccountNumber': 'CU001',
      'customerName': 'Cliente de Prueba 1',
      'date': DateTime.now().toIso8601String(),
      'status': 'Pendiente',
      'total': 1000.00,
      'items': [
        {
          'articleCode': 'PROD-1',
          'description': 'Producto A',
          'quantity': 2,
          'unitPrice': 500.00,
          'subtotal': 1000.00
        }
      ]
    });
  }

  @override
  Future<String> createOrder({
    required String deliveryAddress,
    required String deliveryContact,
    required String deliveryPhone,
    String? notes,
    String? estimatedDeliveryDate,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'ORD-${DateTime.now().millisecondsSinceEpoch}';
  }
}
