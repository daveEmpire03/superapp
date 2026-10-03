import 'package:bokku_mart/features/cart/domain/entities/cart_item_entity.dart';

import '../../domain/entities/address_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/store_location_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';
import '../models/address_model.dart';
import '../models/store_location_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AddressEntity>> getAddresses() async {
    return await remoteDataSource.getAddresses();
  }

  @override
  Future<List<StoreLocationEntity>> getStoreLocations() async {
    return await remoteDataSource.getStoreLocations();
  }

  @override
  Future<List<OrderEntity>> getOrderHistory() async {
    return await remoteDataSource.getOrderHistory();
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    return await remoteDataSource.getOrderById(orderId);
  }

  @override
  Future<OrderEntity> placeOrder({
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
    return await remoteDataSource.createOrder(
      items: items,
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      total: total,
      deliveryMethod: deliveryMethod,
      deliveryAddress: deliveryAddress is AddressModel
          ? deliveryAddress
          : (deliveryAddress != null
              ? AddressModel(
                  id: deliveryAddress.id,
                  label: deliveryAddress.label,
                  fullName: deliveryAddress.fullName,
                  phoneNumber: deliveryAddress.phoneNumber,
                  state: deliveryAddress.state,
                  city: deliveryAddress.city,
                  area: deliveryAddress.area,
                  streetAddress: deliveryAddress.streetAddress,
                  landmark: deliveryAddress.landmark,
                  isDefault: deliveryAddress.isDefault,
                )
              : null),
      pickupStore: pickupStore is StoreLocationModel
          ? pickupStore
          : (pickupStore != null
              ? StoreLocationModel(
                  id: pickupStore.id,
                  name: pickupStore.name,
                  address: pickupStore.address,
                  city: pickupStore.city,
                  area: pickupStore.area,
                  distance: pickupStore.distance,
                  openingHours: pickupStore.openingHours,
                  isOpen: pickupStore.isOpen,
                  phone: pickupStore.phone,
                  services: pickupStore.services,
                )
              : null),
      paymentMethod: paymentMethod,
    );
  }
}
