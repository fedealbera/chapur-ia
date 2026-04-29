import 'package:dartz/dartz.dart';
import '../entities/product.dart';
import '../../core/error/failures.dart';

abstract class IProductRepository {
  Future<Either<Failure, List<Product>>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? priceListCode,
    List<String>? productTypes,
    List<int>? brandCodes,
  });

  Future<Either<Failure, Product>> getProductDetail({
    required String productType,
    required String articleCode,
  });
}
