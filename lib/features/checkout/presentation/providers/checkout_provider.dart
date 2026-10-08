import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/store_location_entity.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

class CheckoutData {
  final List<AddressEntity> addresses;
  final List<StoreLocationEntity> stores;
  const CheckoutData({required this.addresses, required this.stores});
}

final checkoutDataProvider = FutureProvider<CheckoutData>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);
  final addresses = await repository.getAddresses();
  final stores = await repository.getStoreLocations();
  return CheckoutData(addresses: addresses, stores: stores);
});

class CheckoutController extends AsyncNotifier<OrderEntity?> {
  @override
  Future<OrderEntity?> build() async => null;

  Future<void> placeOrder({
    required List<CartItemEntity> items,
    required double subtotal,
    required double discount,
    required double deliveryFee,
    required double total,
    required String deliveryMethod,
    AddressEntity? deliveryAddress,
    StoreLocationEntity? pickupStore,
    required String paymentMethod,
  }) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(orderRepositoryProvider).placeOrder(
      items: items,
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      total: total,
      deliveryMethod: deliveryMethod,
      deliveryAddress: deliveryAddress,
      pickupStore: pickupStore,
      paymentMethod: paymentMethod,
    ));
  }
}

final checkoutControllerProvider =
    AsyncNotifierProvider<CheckoutController, OrderEntity?>(CheckoutController.new);

final orderHistoryProvider = FutureProvider<List<OrderEntity>>(
  (ref) => ref.watch(orderRepositoryProvider).getOrderHistory(),
);

final orderDetailProvider = FutureProvider.family<OrderEntity, String>(
  (ref, orderId) => ref.watch(orderRepositoryProvider).getOrderById(orderId),
);
