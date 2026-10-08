import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../bloc/checkout_event.dart';
import '../bloc/checkout_state.dart';


typedef Emitter<T> = void Function(T value);

final checkoutStateProvider = NotifierProvider<CheckoutController, CheckoutState>(
  CheckoutController.new,
);

class CheckoutController extends Notifier<CheckoutState> {
  OrderRepository get orderRepository => ref.read(orderRepositoryProvider);

  @override
  CheckoutState build() => CheckoutInitial();

  void _emit(CheckoutState value) { state = value; }

  Future<void> add(CheckoutEvent event) async {
    if (event is LoadCheckoutInitialDataEvent) {
      await _onLoadInitialData(event, _emit);
    }     else if (event is SelectDeliveryMethodEvent) {
      await _onSelectDeliveryMethod(event, _emit);
    }     else if (event is SelectAddressEvent) {
      await _onSelectAddress(event, _emit);
    }     else if (event is SelectPickupStoreEvent) {
      await _onSelectPickupStore(event, _emit);
    }     else if (event is SelectPaymentMethodEvent) {
      await _onSelectPaymentMethod(event, _emit);
    }     else if (event is SubmitPlaceOrderEvent) {
      await _onSubmitPlaceOrder(event, _emit);
    }
  }

  Future<void> _onLoadInitialData(
    LoadCheckoutInitialDataEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    try {
      final addresses = await orderRepository.getAddresses();
      final stores = await orderRepository.getStoreLocations();

      emit(CheckoutDataLoaded(
        addresses: addresses,
        stores: stores,
        selectedAddress: addresses.isNotEmpty ? addresses.first : null,
        selectedStore: stores.isNotEmpty ? stores.first : null,
      ));
    } catch (e) {
      emit(CheckoutError(e.toString()));
    }
  }

  void _onSelectDeliveryMethod(
    SelectDeliveryMethodEvent event,
    Emitter<CheckoutState> emit,
  ) {
    final cur = state;
    if (cur is CheckoutDataLoaded) {
      emit(cur.copyWith(deliveryMethod: event.method));
    }
  }

  void _onSelectAddress(
    SelectAddressEvent event,
    Emitter<CheckoutState> emit,
  ) {
    final cur = state;
    if (cur is CheckoutDataLoaded) {
      emit(cur.copyWith(selectedAddress: event.address));
    }
  }

  void _onSelectPickupStore(
    SelectPickupStoreEvent event,
    Emitter<CheckoutState> emit,
  ) {
    final cur = state;
    if (cur is CheckoutDataLoaded) {
      emit(cur.copyWith(selectedStore: event.store));
    }
  }

  void _onSelectPaymentMethod(
    SelectPaymentMethodEvent event,
    Emitter<CheckoutState> emit,
  ) {
    final cur = state;
    if (cur is CheckoutDataLoaded) {
      emit(cur.copyWith(selectedPaymentMethod: event.paymentMethod));
    }
  }

  Future<void> _onSubmitPlaceOrder(
    SubmitPlaceOrderEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    final cur = state;
    if (cur is! CheckoutDataLoaded) return;

    emit(cur.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final order = await orderRepository.placeOrder(
        items: event.items,
        subtotal: event.subtotal,
        discount: event.discount,
        deliveryFee: event.deliveryFee,
        total: event.total,
        deliveryMethod: cur.deliveryMethod,
        deliveryAddress:
            cur.deliveryMethod == 'delivery' ? cur.selectedAddress : null,
        pickupStore: cur.deliveryMethod == 'pickup' ? cur.selectedStore : null,
        paymentMethod: cur.selectedPaymentMethod,
      );

      emit(cur.copyWith(isSubmitting: false, placedOrder: order));
      emit(CheckoutOrderPlacedSuccess(order));
    } catch (e) {
      emit(cur.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to process order: ${e.toString()}',
      ));
    }
  }
}
