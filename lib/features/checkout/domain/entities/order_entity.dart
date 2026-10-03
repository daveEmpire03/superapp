import 'package:bokku_mart/features/cart/domain/entities/cart_item_entity.dart';
import 'package:equatable/equatable.dart';
import 'address_entity.dart';
import 'store_location_entity.dart';

enum OrderStatus {
  confirmed,
  preparing,
  readyDispatch,
  outForDelivery,
  delivered,
  cancelled,
}

class RiderInfo extends Equatable {
  final String name;
  final String phone;
  final String vehicle;
  final double rating;

  const RiderInfo({
    required this.name,
    required this.phone,
    required this.vehicle,
    required this.rating,
  });

  @override
  List<Object?> get props => [name, phone, vehicle, rating];
}

class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final String date;
  final OrderStatus status;
  final List<CartItemEntity> items;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final String deliveryMethod; // 'delivery' or 'pickup'
  final AddressEntity? deliveryAddress;
  final StoreLocationEntity? pickupStore;
  final String paymentMethod;
  final String estimatedArrival;
  final RiderInfo? rider;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    required this.deliveryMethod,
    this.deliveryAddress,
    this.pickupStore,
    required this.paymentMethod,
    required this.estimatedArrival,
    this.rider,
  });

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        date,
        status,
        items,
        subtotal,
        discount,
        deliveryFee,
        total,
        deliveryMethod,
        deliveryAddress,
        pickupStore,
        paymentMethod,
        estimatedArrival,
        rider,
      ];
}
