import 'package:chapur_ia/data/models/product_model.dart';
import 'package:dio/dio.dart';

abstract class IProductRemoteDataSource {
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    List<String>? productTypes,
    List<int>? brandCodes,
  });

  Future<ProductModel> getProductDetail(String productType, String articleCode);
}

class ProductRemoteDataSourceImpl implements IProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    List<String>? productTypes,
    List<int>? brandCodes,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final allItems = [
      {
        'productType': '1',
        'articleCode': 'ART_01',
        'name': 'Laptop Dell Latitude',
        'description': 'Laptop para trabajo corporativo',
        'brandCode': 1,
        'brandName': 'Dell',
        'unitPrice': 1200000.0,
        'priceListCode': '1',
        'imageUrl': '',
        'stockStatus': 'DISPONIBLE',
        'stockQuantity': 50,
      },
      {
        'productType': '1',
        'articleCode': 'ART_02',
        'name': 'Monitor Samsung 24"',
        'description': 'Monitor LED Full HD',
        'brandCode': 2,
        'brandName': 'Samsung',
        'unitPrice': 300000.0,
        'priceListCode': '1',
        'imageUrl': '',
        'stockStatus': 'DISPONIBLE',
        'stockQuantity': 20,
      }
    ];

    List<dynamic> filteredItems = allItems;
    if (search != null && search.isNotEmpty) {
      filteredItems = allItems.where((item) => 
        item['name'].toString().toLowerCase().contains(search.toLowerCase()) || 
        item['articleCode'].toString().toLowerCase().contains(search.toLowerCase())
      ).toList();
    }

    return {
      'items': filteredItems,
      'total': filteredItems.length,
      'page': page,
      'pageSize': pageSize,
    };
  }

  @override
  Future<ProductModel> getProductDetail(String productType, String articleCode) async {
    await Future.delayed(const Duration(seconds: 1));
    return ProductModel.fromJson({
      'productType': productType,
      'articleCode': articleCode,
      'name': 'Producto Demo $articleCode',
      'description': 'Descripción extendida del producto',
      'brandCode': 1,
      'brandName': 'Marca Demo',
      'unitPrice': 150000.0,
      'priceListCode': '1',
      'imageUrl': '',
      'stockStatus': 'DISPONIBLE',
      'stockQuantity': 100,
    });
  }
}
