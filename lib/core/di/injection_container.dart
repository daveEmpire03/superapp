import 'package:bokku_mart/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../location/location_service.dart';
import '../network/dio_client.dart';
import '../storage/auth_token_storage.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Catalog
import '../../features/catalog/data/datasources/product_remote_data_source.dart';
import '../../features/catalog/data/repositories/product_repository_impl.dart';
import '../../features/catalog/domain/repositories/product_repository.dart';
import '../../features/catalog/presentation/bloc/product_bloc.dart';

// Cart
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';

// Checkout
import '../../features/checkout/data/datasources/order_remote_data_source.dart';
import '../../features/checkout/data/repositories/order_repository_impl.dart';
import '../../features/checkout/domain/repositories/order_repository.dart';
import '../../features/checkout/presentation/bloc/checkout_bloc.dart';

// Stores
import '../../features/stores/data/datasources/store_local_data_source.dart';
import '../../features/stores/data/datasources/store_remote_data_source.dart';
import '../../features/stores/data/repositories/store_repository.dart';
import '../../features/stores/data/repositories/store_repository_impl.dart';
import '../../features/stores/presentation/bloc/store_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  sl.registerLazySingleton<SharedPreferences>(
    () => sharedPreferences,
  );

  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton<AuthTokenStorage>(
    () => AuthTokenStorage(
      secureStorage: sl<FlutterSecureStorage>(),
    ),
  );

  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      tokenStorage: sl<AuthTokenStorage>(),
    ),
  );

  sl.registerLazySingleton<LocationService>(
    () => LocationServiceImpl(),
  );

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dioClient: sl<DioClient>(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      tokenStorage: sl<AuthTokenStorage>(),
    ),
  );

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: sl<AuthRepository>(),
    ),
  );

  // Catalog
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(
      dioClient: sl<DioClient>(),
    ),
  );

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl<ProductRemoteDataSource>(),
    ),
  );

  sl.registerFactory<ProductBloc>(
    () => ProductBloc(
      productRepository: sl<ProductRepository>(),
    ),
  );

  // Cart
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(
      dioClient: sl<DioClient>(),
    ),
  );

  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      remoteDataSource: sl<CartRemoteDataSource>(),
    ),
  );

  sl.registerFactory<CartBloc>(
    () => CartBloc(
      cartRepository: sl<CartRepository>(),
    ),
  );

  // Checkout
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(
      dioClient: sl<DioClient>(),
    ),
  );

  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      remoteDataSource: sl<OrderRemoteDataSource>(),
    ),
  );

  sl.registerFactory<CheckoutBloc>(
    () => CheckoutBloc(
      orderRepository: sl<OrderRepository>(),
    ),
  );

  // Stores
  sl.registerLazySingleton<StoreRemoteDataSource>(
    () => StoreRemoteDataSourceImpl(
      dioClient: sl<DioClient>(),
    ),
  );

  sl.registerLazySingleton<StoreLocalDataSource>(
    () => StoreLocalDataSourceImpl(
      sharedPreferences: sl<SharedPreferences>(),
    ),
  );

  sl.registerLazySingleton<StoreRepository>(
    () => StoreRepositoryImpl(
      remoteDataSource: sl<StoreRemoteDataSource>(),
      localDataSource: sl<StoreLocalDataSource>(),
    ),
  );

  sl.registerFactory<StoreBloc>(
    () => StoreBloc(
      storeRepository: sl<StoreRepository>(),
      locationService: sl<LocationService>(),
    ),
  );
}
