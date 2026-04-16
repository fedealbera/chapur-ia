import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/product.dart';
import '../../repositories/i_product_repository.dart';

class GetProductsUseCase {
  final IProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<Product>>> execute({
    int page = 1,
    int pageSize = 20,
    String? search,
    List<String>? productTypes,
    List<int>? brandCodes,
  }) {
    return repository.getProducts(
      page: page,
      pageSize: pageSize,
      search: search,
      productTypes: productTypes,
      brandCodes: brandCodes,
    );
  }
}

class GetProductDetailUseCase {
  final IProductRepository repository;

  GetProductDetailUseCase(this.repository);

  Future<Either<Failure, Product>> execute({
    required String productType,
    required String articleCode,
  }) {
    return repository.getProductDetail(
      productType: productType,
      articleCode: articleCode,
    );
  }
}
