import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/injection_container.dart';
import '../location/location_service.dart';
import '../network/dio_client.dart';
import '../storage/auth_token_storage.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/catalog/domain/repositories/product_repository.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/checkout/domain/repositories/order_repository.dart';
import '../../features/stores/data/repositories/store_repository.dart';

/// Temporary infrastructure bridge during the incremental BLoC migration.
///
/// Existing repositories are owned by GetIt. Riverpod must not dispose them.
/// Replace each bridge provider with a Riverpod-owned factory when its feature
/// migrates; this prevents creating duplicate network clients or token stores.
final dioClientProvider = Provider<DioClient>((ref) => sl<DioClient>());
final authTokenStorageProvider =
    Provider<AuthTokenStorage>((ref) => sl<AuthTokenStorage>());
final locationServiceProvider =
    Provider<LocationService>((ref) => sl<LocationService>());

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => sl<AuthRepository>());
final productRepositoryProvider =
    Provider<ProductRepository>((ref) => sl<ProductRepository>());
final cartRepositoryProvider =
    Provider<CartRepository>((ref) => sl<CartRepository>());
final orderRepositoryProvider =
    Provider<OrderRepository>((ref) => sl<OrderRepository>());
final storeRepositoryProvider =
    Provider<StoreRepository>((ref) => sl<StoreRepository>());
