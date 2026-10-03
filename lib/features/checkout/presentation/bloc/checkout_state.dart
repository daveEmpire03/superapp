import 'package:equatable/equatable.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/store_location_entity.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutDataLoaded extends CheckoutState {
  final List<AddressEntity> addresses;
  final List<StoreLocationEntity> stores;
  final String deliveryMethod; // 'delivery' | 'pickup'
  final AddressEntity? selectedAddress;
  final StoreLocationEntity? selectedStore;
  final String selectedPaymentMethod;
  final bool isSubmitting;
  final OrderEntity? placedOrder;
  final String? errorMessage;

  const CheckoutDataLoaded({
    required this.addresses,
    required this.stores,
    this.deliveryMethod = 'delivery',
    this.selectedAddress,
    this.selectedStore,
    this.selectedPaymentMethod = 'Instant Card (Paystack/Flutterwave)',
    this.isSubmitting = false,
    this.placedOrder,
    this.errorMessage,
  });

  CheckoutDataLoaded copyWith({
    List<AddressEntity>? addresses,
    List<StoreLocationEntity>? stores,
    String? deliveryMethod,
    AddressEntity? selectedAddress,
    StoreLocationEntity? selectedStore,
    String? selectedPaymentMethod,
    bool? isSubmitting,
    OrderEntity? placedOrder,
    String? errorMessage,
  }) {
    return CheckoutDataLoaded(
      addresses: addresses ?? this.addresses,
      stores: stores ?? this.stores,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedStore: selectedStore ?? this.selectedStore,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      placedOrder: placedOrder ?? this.placedOrder,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        addresses,
        stores,
        deliveryMethod,
        selectedAddress,
        selectedStore,
        selectedPaymentMethod,
        isSubmitting,
        placedOrder,
        errorMessage,
      ];
}

class CheckoutOrderPlacedSuccess extends CheckoutState {
  final OrderEntity order;

  const CheckoutOrderPlacedSuccess(this.order);

  @override
  List<Object?> get props => [order];
}

class CheckoutError extends CheckoutState {
  final String message;

  const CheckoutError(this.message);

  @override
  List<Object?> get props => [message];
}
