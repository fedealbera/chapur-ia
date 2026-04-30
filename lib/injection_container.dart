import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chapur_ia/core/constants/constants.dart';

// Auth
import 'package:chapur_ia/core/network/dio_interceptor.dart';
import 'package:chapur_ia/data/datasources/remote/auth_remote_data_source.dart';
import 'package:chapur_ia/data/repositories/auth_repository_impl.dart';
import 'package:chapur_ia/domain/repositories/i_auth_repository.dart';
import 'package:chapur_ia/domain/usecases/auth/login_use_case.dart';
import 'package:chapur_ia/presentation/blocs/auth/auth_bloc.dart';

// Products
import 'package:chapur_ia/data/datasources/remote/product_remote_data_source.dart';
import 'package:chapur_ia/data/repositories/product_repository_impl.dart';
import 'package:chapur_ia/domain/repositories/i_product_repository.dart';
import 'package:chapur_ia/domain/usecases/products/get_products_use_case.dart';
import 'package:chapur_ia/presentation/blocs/product/product_bloc.dart';

// Customers
import 'package:chapur_ia/data/datasources/remote/customer_remote_data_source.dart';
import 'package:chapur_ia/data/repositories/customer_repository_impl.dart';
import 'package:chapur_ia/domain/repositories/i_customer_repository.dart';
import 'package:chapur_ia/domain/usecases/customers/customer_use_cases.dart';
import 'package:chapur_ia/presentation/blocs/customer/customer_bloc.dart';

// Orders
import 'package:chapur_ia/data/datasources/remote/order_remote_data_source.dart';
import 'package:chapur_ia/data/repositories/order_repository_impl.dart';
import 'package:chapur_ia/domain/repositories/i_order_repository.dart';
import 'package:chapur_ia/domain/usecases/orders/order_use_cases.dart';
import 'package:chapur_ia/presentation/blocs/order/order_bloc.dart';

// Account
import 'package:chapur_ia/data/datasources/remote/account_remote_data_source.dart';
import 'package:chapur_ia/data/repositories/account_repository_impl.dart';
import 'package:chapur_ia/domain/repositories/i_account_repository.dart';
import 'package:chapur_ia/domain/usecases/account/account_use_cases.dart';
import 'package:chapur_ia/presentation/blocs/account/account_bloc.dart';

// Cart
import 'package:chapur_ia/data/datasources/remote/cart_remote_data_source.dart';
import 'package:chapur_ia/data/repositories/cart_repository_impl.dart';
import 'package:chapur_ia/domain/repositories/i_cart_repository.dart';
import 'package:chapur_ia/domain/usecases/cart/get_cart_use_case.dart';
import 'package:chapur_ia/domain/usecases/cart/add_item_to_cart_use_case.dart';
import 'package:chapur_ia/domain/usecases/cart/clear_cart_use_case.dart';
import 'package:chapur_ia/presentation/blocs/cart/cart_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        authRepository: sl(),
      ));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(
        remoteDataSource: sl(),
        secureStorage: sl(),
      ));
  sl.registerLazySingleton<IAuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(dio: sl()));

  //! Features - Products
  sl.registerFactory(() => ProductBloc(
        getProductsUseCase: sl(),
        getProductDetailUseCase: sl(),
      ));
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductDetailUseCase(sl()));
  sl.registerLazySingleton<IProductRepository>(
      () => ProductRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<IProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(dio: sl()));

  //! Features - Customers
  sl.registerFactory(() => CustomerBloc(
        searchCustomersUseCase: sl(),
        getCustomerDetailUseCase: sl(),
      ));
  sl.registerLazySingleton(() => SearchCustomersUseCase(sl()));
  sl.registerLazySingleton(() => GetCustomerDetailUseCase(sl()));
  sl.registerLazySingleton<ICustomerRepository>(
      () => CustomerRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ICustomerRemoteDataSource>(
      () => CustomerRemoteDataSourceImpl(dio: sl()));

  //! Features - Orders
  sl.registerFactory(() => OrderBloc(
        getOrdersUseCase: sl(),
        getOrderDetailUseCase: sl(),
        createOrderUseCase: sl(),
      ));
  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderDetailUseCase(sl()));
  sl.registerLazySingleton(() => CreateOrderUseCase(sl()));
  sl.registerLazySingleton<IOrderRepository>(
      () => OrderRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<IOrderRemoteDataSource>(
      () => OrderRemoteDataSourceImpl(dio: sl()));

  //! Features - Account (Cta Cte)
  sl.registerFactory(() => AccountBloc(
        getAccountSummaryUseCase: sl(),
        getDocumentDetailUseCase: sl(),
        getDocumentPdfUseCase: sl(),
      ));
  sl.registerLazySingleton(() => GetAccountSummaryUseCase(sl()));
  sl.registerLazySingleton(() => GetDocumentDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetDocumentPdfUseCase(sl()));
  sl.registerLazySingleton<IAccountRepository>(
      () => AccountRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<IAccountRemoteDataSource>(
      () => AccountRemoteDataSourceImpl(dio: sl()));

  //! Features - Cart
  sl.registerFactory(() => CartBloc(
        getCartUseCase: sl(),
        addItemToCartUseCase: sl(),
        clearCartUseCase: sl(),
      ));
  sl.registerLazySingleton(() => GetCartUseCase(repository: sl()));
  sl.registerLazySingleton(() => AddItemToCartUseCase(repository: sl()));
  sl.registerLazySingleton(() => ClearCartUseCase(repository: sl()));
  sl.registerLazySingleton<ICartRepository>(
      () => CartRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ICartRemoteDataSource>(
      () => CartRemoteDataSourceImpl(dio: sl()));

  //! Core
  // sl.registerLazySingleton(() => NetworkInfo(sl()));

  //! External
  const storage = FlutterSecureStorage();
  sl.registerLazySingleton(() => storage);

  sl.registerLazySingleton(() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept-Language': 'en-US',
      },
    ));
    
    dio.interceptors.add(AuthInterceptor(secureStorage: sl()));
    
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
    
    return dio;
  });
}
