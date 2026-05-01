import 'package:chapur_ia/data/models/product_model.dart';
import 'package:dio/dio.dart';

abstract class IProductRemoteDataSource {
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? priceListCode,
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
    String? priceListCode,
    List<String>? productTypes,
    List<int>? brandCodes,
  }) async {
    try {
      final isSearch = search != null && search.isNotEmpty;
      final endpoint = isSearch ? '/products/search' : '/products';

      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (isSearch) {
        queryParams['q'] = search;
      }

      if (priceListCode != null) {
        queryParams['priceListCode'] = priceListCode;
      }

      if (productTypes != null && productTypes.isNotEmpty) {
        queryParams['productType'] = productTypes;
      }

      if (brandCodes != null && brandCodes.isNotEmpty) {
        queryParams['brandCode'] = brandCodes;
      }

      final response = await dio.get(
        endpoint,
        queryParameters: queryParams,
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        throw const FormatException('La respuesta del servidor no tiene el formato esperado.');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProductModel> getProductDetail(String productType, String articleCode) async {
    try {
      final response = await dio.get('/products/$productType/$articleCode');
      if (response.data is Map<String, dynamic>) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw const FormatException('La respuesta del servidor no tiene el formato esperado.');
      }
    } catch (e) {
      rethrow;
    }
  }
}
