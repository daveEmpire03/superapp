import 'package:bokku_mart/features/cart/data/models/cart_item_model.dart';
import 'package:bokku_mart/features/cart/domain/entities/cart_item_entity.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/address_model.dart';
import '../models/order_model.dart';
import '../models/store_location_model.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrderRemoteDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<List<StoreLocationModel>> getStoreLocations();
  Future<List<OrderModel>> getOrderHistory();
  Future<OrderModel> getOrderById(String orderId);
  Future<OrderModel> createOrder({
    required List<CartItemEntity> items,
    required double subtotal,
    required double discount,
    required double deliveryFee,
    required double total,
    required String deliveryMethod,
    AddressModel? deliveryAddress,
    StoreLocationModel? pickupStore,
    required String paymentMethod,
  });
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient dioClient;

  OrderRemoteDataSourceImpl({required this.dioClient});

  static final List<AddressModel> _mockAddresses = [
    const AddressModel(
      id: 'addr-1',
      label: 'Home',
      fullName: 'Chinedu Eze',
      phoneNumber: '+234 803 123 4567',
      state: 'Lagos State',
      city: 'Lagos',
      area: 'Lekki Phase 1',
      streetAddress: 'Flat 4B, Block 12, Admiralty Way',
      landmark: 'Opposite Domino’s Pizza',
      isDefault: true,
    ),
    const AddressModel(
      id: 'addr-2',
      label: 'Work',
      fullName: 'Chinedu Eze',
      phoneNumber: '+234 803 123 4567',
      state: 'Lagos State',
      city: 'Lagos',
      area: 'Victoria Island',
      streetAddress: 'Floor 7, Landmark Towers, Water Corporation Drive',
      landmark: 'Near Hard Rock Cafe',
      isDefault: false,
    ),
    const AddressModel(
      id: 'addr-3',
      label: 'Other',
      fullName: 'Mama Chinedu',
      phoneNumber: '+234 802 987 6543',
      state: 'Lagos State',
      city: 'Lagos',
      area: 'Ikeja GRA',
      streetAddress: '15 Isaac John Street',
      landmark: 'Beside Radisson Blu Hotel',
      isDefault: false,
    ),
  ];

  static final List<StoreLocationModel> _mockStores = [
    const StoreLocationModel(
      id: 'store-1',
      name: 'Bokku Mart - Ikeja City Mall Flagship',
      address: 'Obafemi Awolowo Way, Alausa, Ikeja',
      city: 'Lagos',
      area: 'Ikeja',
      distance: '1.2 km away',
      openingHours: '7:30 AM – 10:00 PM',
      isOpen: true,
      phone: '0700-BOKKU-IKEJA',
      services: [
        'Bakery Fresh',
        'Express 15-min Pickup',
        'Car Trunk Loading',
        'POS & Cash'
      ],
    ),
    const StoreLocationModel(
      id: 'store-2',
      name: 'Bokku Mart - Victoria Island Central',
      address: 'Plot 1042 Adeola Odeku Street, Victoria Island',
      city: 'Lagos',
      area: 'Victoria Island',
      distance: '3.8 km away',
      openingHours: '7:00 AM – 11:00 PM',
      isOpen: true,
      phone: '0700-BOKKU-VI',
      services: ['Butchery', 'Express Pickup', 'Wine Cellar', 'Valet Parking'],
    ),
    const StoreLocationModel(
      id: 'store-3',
      name: 'Bokku Mart - Lekki Admiralty Hub',
      address: 'Plot 2 Admiralty Way, Lekki Phase 1',
      city: 'Lagos',
      area: 'Lekki',
      distance: '2.4 km away',
      openingHours: '7:30 AM – 10:30 PM',
      isOpen: true,
      phone: '0700-BOKKU-LEKKI',
      services: ['Produce Cold Room', 'Curbside Pickup', 'Pharmacy Corner'],
    ),
    const StoreLocationModel(
      id: 'store-4',
      name: 'Bokku Mart - Yaba Commercial Hub',
      address: '320 Herbert Macaulay Way, Alagomeji, Yaba',
      city: 'Lagos',
      area: 'Yaba',
      distance: '5.2 km away',
      openingHours: '8:00 AM – 9:00 PM',
      isOpen: true,
      phone: '0700-BOKKU-YABA',
      services: ['Student Discounts', 'Instant Counter Pickup'],
    ),
  ];

  final List<OrderModel> _orders = [
    OrderModel(
      id: 'order-1',
      orderNumber: 'BM-84920',
      date: 'Today, 10:24 AM',
      status: OrderStatus.outForDelivery,
      items: const [],
      subtotal: 15350,
      discount: 1000,
      deliveryFee: 1200,
      total: 15550,
      deliveryMethod: 'delivery',
      deliveryAddress: _mockAddresses[0],
      paymentMethod: 'Debit Card (Mastercard ending 4921)',
      estimatedArrival: '11:15 AM (approx. 18 mins)',
      rider: const RiderInfo(
        name: 'Babatunde Olawale',
        phone: '+234 809 112 3344',
        vehicle: 'TVS Neo Motorcycle (EKY-492-LG)',
        rating: 4.9,
      ),
    ),
    OrderModel(
      id: 'order-2',
      orderNumber: 'BM-79341',
      date: '22 Sep 2026, 4:15 PM',
      status: OrderStatus.delivered,
      items: const [],
      subtotal: 28100,
      discount: 1500,
      deliveryFee: 1200,
      total: 27800,
      deliveryMethod: 'delivery',
      deliveryAddress: _mockAddresses[0],
      paymentMethod: 'Instant Bank Transfer',
      estimatedArrival: 'Delivered at 5:02 PM',
    ),
  ];

  @override
  Future<List<AddressModel>> getAddresses() async {
    try {
      final res = await dioClient.get(ApiEndpoints.addresses);
      return (res.data as List)
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _mockAddresses;
    }
  }

  @override
  Future<List<StoreLocationModel>> getStoreLocations() async {
    try {
      final res = await dioClient.get(ApiEndpoints.stores);
      return (res.data as List)
          .map((e) => StoreLocationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _mockStores;
    }
  }

  @override
  Future<List<OrderModel>> getOrderHistory() async {
    try {
      final res = await dioClient.get(ApiEndpoints.orders);
      return (res.data as List)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _orders;
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    return _orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => _orders.first,
    );
  }

  @override
  Future<OrderModel> createOrder({
    required List<CartItemEntity> items,
    required double subtotal,
    required double discount,
    required double deliveryFee,
    required double total,
    required String deliveryMethod,
    AddressModel? deliveryAddress,
    StoreLocationModel? pickupStore,
    required String paymentMethod,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final newOrder = OrderModel(
      id: 'order-${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: 'BM-${10000 + (DateTime.now().millisecond * 70 % 89999)}',
      date: 'Just now',
      status: OrderStatus.confirmed,
      items: items.map((i) => CartItemModel.fromEntity(i)).toList(),
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      total: total,
      deliveryMethod: deliveryMethod,
      deliveryAddress: deliveryAddress ?? _mockAddresses.first,
      pickupStore: pickupStore,
      paymentMethod: paymentMethod,
      estimatedArrival: '35 - 45 mins',
      rider: const RiderInfo(
        name: 'Tunde Lawal',
        phone: '+234 814 000 1122',
        vehicle: 'Yamaha Crux (APP-821-YK)',
        rating: 4.95,
      ),
    );

    _orders.insert(0, newOrder);
    return newOrder;
  }
}
