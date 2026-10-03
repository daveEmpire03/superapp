import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/order_repository.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final OrderRepository orderRepository;

  CheckoutBloc({required this.orderRepository}) : super(CheckoutInitial()) {
    on<LoadCheckoutInitialDataEvent>(_onLoadInitialData);
    on<SelectDeliveryMethodEvent>(_onSelectDeliveryMethod);
    on<SelectAddressEvent>(_onSelectAddress);
    on<SelectPickupStoreEvent>(_onSelectPickupStore);
    on<SelectPaymentMethodEvent>(_onSelectPaymentMethod);
    on<SubmitPlaceOrderEvent>(_onSubmitPlaceOrder);
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
