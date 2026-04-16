import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/usecases/products/get_products_use_case.dart';

// --- Events ---
abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class FetchProductsRequested extends ProductEvent {
  final bool reset;
  final String? search;
  final List<int>? brandCodes;

  const FetchProductsRequested({
    this.reset = false,
    this.search,
    this.brandCodes,
  });

  @override
  List<Object?> get props => [reset, search, brandCodes];
}

class ProductDetailRequested extends ProductEvent {
  final String productType;
  final String articleCode;

  const ProductDetailRequested({
    required this.productType,
    required this.articleCode,
  });

  @override
  List<Object?> get props => [productType, articleCode];
}

// --- States ---
abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductListLoaded extends ProductState {
  final List<Product> products;
  final bool hasReachedMax;
  final String? search;
  final List<int>? brandCodes;

  const ProductListLoaded({
    required this.products,
    required this.hasReachedMax,
    this.search,
    this.brandCodes,
  });

  @override
  List<Object?> get props => [products, hasReachedMax, search, brandCodes];

  ProductListLoaded copyWith({
    List<Product>? products,
    bool? hasReachedMax,
    String? search,
    List<int>? brandCodes,
  }) {
    return ProductListLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      search: search ?? this.search,
      brandCodes: brandCodes ?? this.brandCodes,
    );
  }
}

class ProductDetailLoaded extends ProductState {
  final Product product;
  const ProductDetailLoaded(this.product);
  @override
  List<Object?> get props => [product];
}

class ProductFailure extends ProductState {
  final String message;
  const ProductFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductDetailUseCase getProductDetailUseCase;

  int _currentPage = 1;
  static const int _pageSize = 20;

  ProductBloc({
    required this.getProductsUseCase,
    required this.getProductDetailUseCase,
  }) : super(ProductInitial()) {
    on<FetchProductsRequested>(_onFetchProducts);
    on<ProductDetailRequested>(_onProductDetail);
  }

  Future<void> _onFetchProducts(
    FetchProductsRequested event,
    Emitter<ProductState> emit,
  ) async {
    if (event.reset) {
      _currentPage = 1;
      emit(ProductLoading());
    }

    final currentState = state;
    List<Product> oldProducts = [];
    if (currentState is ProductListLoaded && !event.reset) {
      oldProducts = currentState.products;
    }

    final result = await getProductsUseCase.execute(
      page: _currentPage,
      pageSize: _pageSize,
      search: event.search,
      brandCodes: event.brandCodes,
    );

    result.fold(
      (failure) => emit(ProductFailure(failure.message)),
      (newProducts) {
        _currentPage++;
        emit(ProductListLoaded(
          products: oldProducts + newProducts,
          hasReachedMax: newProducts.length < _pageSize,
          search: event.search,
          brandCodes: event.brandCodes,
        ));
      },
    );
  }

  Future<void> _onProductDetail(
    ProductDetailRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final result = await getProductDetailUseCase.execute(
      productType: event.productType,
      articleCode: event.articleCode,
    );

    result.fold(
      (failure) => emit(ProductFailure(failure.message)),
      (product) => emit(ProductDetailLoaded(product)),
    );
  }
}
