import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderLoaded extends OrderState {
  final List<OrderEntity> orders;
  final BackendOrderStatus? statusFilter;
  final bool activeOnly;

  const OrderLoaded({
    required this.orders,
    this.statusFilter,
    this.activeOnly = false,
  });

  bool get isEmpty => orders.isEmpty;
  bool get isNotEmpty => orders.isNotEmpty;

  List<OrderEntity> get activeOrders =>
      orders.where((o) => o.isActive).toList();

  List<OrderEntity> get pastOrders =>
      orders.where((o) => !o.isActive).toList();

  List<OrderEntity> get filteredOrders {
    var list = orders;
    if (activeOnly) {
      list = list.where((o) => o.isActive).toList();
    }
    if (statusFilter != null) {
      list = list.where((o) => o.status == statusFilter).toList();
    }
    return list;
  }

  OrderLoaded copyWith({
    List<OrderEntity>? orders,
    BackendOrderStatus? statusFilter,
    bool clearStatusFilter = false,
    bool? activeOnly,
  }) {
    return OrderLoaded(
      orders: orders ?? this.orders,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      activeOnly: activeOnly ?? this.activeOnly,
    );
  }

  @override
  List<Object?> get props => [orders, statusFilter, activeOnly];
}

class OrderError extends OrderState {
  final String message;
  final List<OrderEntity> cachedOrders;

  const OrderError(
    this.message, {
    this.cachedOrders = const [],
  });

  @override
  List<Object?> get props => [message, cachedOrders];
}
