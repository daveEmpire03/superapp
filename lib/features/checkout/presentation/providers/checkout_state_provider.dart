import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/store_location_entity.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../bloc/checkout_state.dart';

final checkoutStateProvider = NotifierProvider<CheckoutController, CheckoutState>(
  CheckoutController.new,
);

class CheckoutController extends Notifier<CheckoutState> {
  OrderRepository get orderRepository => ref.read(orderRepositoryProvider);

  @override
  CheckoutState build() => CheckoutInitial();

  Future<void> loadInitialData() async {
    state = CheckoutLoading();
    try {
      final addresses = await orderRepository.getAddresses();
      final stores = await orderRepository.getStoreLocations();

      state = CheckoutDataLoaded(
        addresses: addresses,
        stores: stores,
        selectedAddress: addresses.isNotEmpty ? addresses.first : null,
        selectedStore: stores.isNotEmpty ? stores.first : null,
      );
    } catch (e) {
      state = CheckoutError(e.toString());
    }
  }

  void selectDeliveryMethod(String method) {
    final cur = state;
    if (cur is CheckoutDataLoaded) {
      state = cur.copyWith(deliveryMethod: method);
    }
  }

  void selectAddress(AddressEntity address) {
    final cur = state;
    if (cur is CheckoutDataLoaded) {
      state = cur.copyWith(selectedAddress: address);
    }
  }

  void selectPickupStore(StoreLocationEntity store) {
    final cur = state;
    if (cur is CheckoutDataLoaded) {
      state = cur.copyWith(selectedStore: store);
    }
  }

  void selectPaymentMethod(String paymentMethod) {
    final cur = state;
    if (cur is CheckoutDataLoaded) {
      state = cur.copyWith(selectedPaymentMethod: paymentMethod);
    }
  }

  Future<void> submitPlaceOrder({
    required List<CartItemEntity> items,
    required double subtotal,
    required double discount,
    required double deliveryFee,
    required double total,
  }) async {
    final cur = state;
    if (cur is! CheckoutDataLoaded) return;

    state = cur.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final order = await orderRepository.placeOrder(
        items: items,
        subtotal: subtotal,
        discount: discount,
        deliveryFee: deliveryFee,
        total: total,
        deliveryMethod: cur.deliveryMethod,
        deliveryAddress:
            cur.deliveryMethod == 'delivery' ? cur.selectedAddress : null,
        pickupStore: cur.deliveryMethod == 'pickup' ? cur.selectedStore : null,
        paymentMethod: cur.selectedPaymentMethod,
      );

      state = cur.copyWith(isSubmitting: false, placedOrder: order);
      state = CheckoutOrderPlacedSuccess(order);
    } catch (e) {
      state = cur.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to process order: ${e.toString()}',
      );
    }
  }


}
