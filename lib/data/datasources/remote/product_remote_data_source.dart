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
    final Map<String, dynamic> queryParams = {
      'page': page,
      'pageSize': pageSize,
    };

    if (search != null) queryParams['search'] = search;
    if (productTypes != null) queryParams['productType'] = productTypes;
    if (brandCodes != null) queryParams['brandCode'] = brandCodes.map((e) => e.toString()).toList();

    final response = await dio.get('/products', queryParameters: queryParams);

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  @override
  Future<ProductModel> getProductDetail(String productType, String articleCode) async {
    final response = await dio.get('/products/$productType/$articleCode');

    if (response.statusCode == 200) {
      return ProductModel.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
