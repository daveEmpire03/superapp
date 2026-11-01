import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../bloc/order_state.dart';

final backendOrderRepositoryProvider = Provider<OrderRepository>(
  (ref) => sl<OrderRepository>(),
);

final orderListProvider =
    NotifierProvider<OrderListController, OrderState>(
  OrderListController.new,
);

final activeOrdersCountProvider = Provider<int>((ref) {
  final state = ref.watch(orderListProvider);
  if (state is OrderLoaded) {
    return state.activeOrders.length;
  }
  return 0;
});

final orderDetailProvider =
    FutureProvider.family<OrderEntity, String>((ref, orderId) async {
  final repository = ref.read(backendOrderRepositoryProvider);
  return repository.getOrderDetail(orderId);
});

class OrderListController extends Notifier<OrderState> {
  OrderRepository get orderRepository =>
      ref.read(backendOrderRepositoryProvider);

  @override
  OrderState build() => const OrderInitial();

  Future<void> loadOrders({bool silent = false}) async {
    final currentState = state;
    if (!silent || currentState is! OrderLoaded) {
      state = const OrderLoading();
    }

    try {
      final orders = await orderRepository.getOrders();
      state = OrderLoaded(
        orders: orders,
        statusFilter: currentState is OrderLoaded ? currentState.statusFilter : null,
        activeOnly: currentState is OrderLoaded ? currentState.activeOnly : false,
      );
    } catch (error) {
      final cached = currentState is OrderLoaded
          ? currentState.orders
          : <OrderEntity>[];
      state = OrderError(
        _errorMessage(error),
        cachedOrders: cached,
      );
    }
  }

  Future<void> refresh() async {
    await loadOrders(silent: true);
  }

  void filterByStatus(BackendOrderStatus? status) {
    final currentState = state;
    if (currentState is! OrderLoaded) return;

    if (currentState.statusFilter == status) {
      state = currentState.copyWith(clearStatusFilter: true);
    } else {
      state = currentState.copyWith(statusFilter: status);
    }
  }

  void toggleActiveOnly() {
    final currentState = state;
    if (currentState is! OrderLoaded) return;

    state = currentState.copyWith(activeOnly: !currentState.activeOnly);
  }

  String _errorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    if (message.startsWith('ArgumentError: ')) {
      return message.substring('ArgumentError: '.length);
    }
    return message;
  }
}
