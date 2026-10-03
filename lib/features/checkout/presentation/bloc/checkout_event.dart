import 'package:equatable/equatable.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/store_location_entity.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class LoadCheckoutInitialDataEvent extends CheckoutEvent {}

class SelectDeliveryMethodEvent extends CheckoutEvent {
  final String method; // 'delivery' or 'pickup'

  const SelectDeliveryMethodEvent(this.method);

  @override
  List<Object?> get props => [method];
}

class SelectAddressEvent extends CheckoutEvent {
  final AddressEntity address;

  const SelectAddressEvent(this.address);

  @override
  List<Object?> get props => [address];
}

class SelectPickupStoreEvent extends CheckoutEvent {
  final StoreLocationEntity store;

  const SelectPickupStoreEvent(this.store);

  @override
  List<Object?> get props => [store];
}

class SelectPaymentMethodEvent extends CheckoutEvent {
  final String paymentMethod;

  const SelectPaymentMethodEvent(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

class SubmitPlaceOrderEvent extends CheckoutEvent {
  final List<CartItemEntity> items;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;

  const SubmitPlaceOrderEvent({
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
  });

  @override
  List<Object?> get props => [items, subtotal, discount, deliveryFee, total];
}
