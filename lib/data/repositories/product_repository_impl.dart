import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../datasources/remote/product_remote_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements IProductRepository {
  final IProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    List<String>? productTypes,
    List<int>? brandCodes,
  }) async {
    try {
      final response = await remoteDataSource.getProducts(
        page: page,
        pageSize: pageSize,
        search: search,
        productTypes: productTypes,
        brandCodes: brandCodes,
      );

      final List<dynamic> itemsJson = response['items'];
      final products = itemsJson.map((json) => ProductModel.fromJson(json)).toList();

      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductDetail({
    required String productType,
    required String articleCode,
  }) async {
    try {
      final product = await remoteDataSource.getProductDetail(productType, articleCode);
      return Right(product);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
