// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notification_state.dart';
import '../providers/notification_state_provider.dart';
import '../widgets/notification_filter_chip.dart';
import '../widgets/notification_item_card.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationStateProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationStateProvider);
    final notifier = ref.read(notificationStateProvider.notifier);

    final unreadCount = state is NotificationLoaded ? state.unreadCount : 0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () => notifier.markAllAsRead(),
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text(
                'Mark all read',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Section
          if (state is NotificationLoaded) _buildFilterBar(state, notifier),

          // Main Content
          Expanded(
            child: switch (state) {
              NotificationInitial() ||
              NotificationLoading() => _buildLoadingState(),
              NotificationError(:final message) => _buildErrorState(message),
              NotificationLoaded() => _buildLoadedState(state, notifier),
              _ => const SizedBox.shrink(),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(
    NotificationLoaded state,
    NotificationController notifier,
  ) {
    final isAll = state.selectedTypeFilter == null && !state.unreadOnlyFilter;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            NotificationFilterChip(
              label: 'All',
              isSelected: isAll,
              onTap: () {
                if (state.unreadOnlyFilter) notifier.toggleUnreadOnly();
                notifier.filterByType(null);
              },
            ),
            const SizedBox(width: 8),
            NotificationFilterChip(
              label: 'Unread',
              isSelected: state.unreadOnlyFilter,
              count: state.unreadCount,
              onTap: () => notifier.toggleUnreadOnly(),
            ),
            const SizedBox(width: 8),
            NotificationFilterChip(
              label: 'Orders',
              isSelected: state.selectedTypeFilter == NotificationType.order,
              onTap: () => notifier.filterByType(NotificationType.order),
            ),
            const SizedBox(width: 8),
            NotificationFilterChip(
              label: 'Delivery',
              isSelected: state.selectedTypeFilter == NotificationType.delivery,
              onTap: () => notifier.filterByType(NotificationType.delivery),
            ),
            const SizedBox(width: 8),
            NotificationFilterChip(
              label: 'Payments',
              isSelected: state.selectedTypeFilter == NotificationType.payment,
              onTap: () => notifier.filterByType(NotificationType.payment),
            ),
            const SizedBox(width: 8),
            NotificationFilterChip(
              label: 'Promotions',
              isSelected:
                  state.selectedTypeFilter == NotificationType.promotion,
              onTap: () => notifier.filterByType(NotificationType.promotion),
            ),
            const SizedBox(width: 8),
            NotificationFilterChip(
              label: 'Loyalty',
              isSelected: state.selectedTypeFilter == NotificationType.loyalty,
              onTap: () => notifier.filterByType(NotificationType.loyalty),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(
    NotificationLoaded state,
    NotificationController notifier,
  ) {
    final items = state.filteredNotifications;

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: notifier.refresh,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            _buildEmptyState(
              hasFilters:
                  state.unreadOnlyFilter || state.selectedTypeFilter != null,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final notification = items[index];
          return NotificationItemCard(
            notification: notification,
            onTap: () => _handleNotificationTap(notification, notifier),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppColors.errorSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Couldn\'t load notifications',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(notificationStateProvider.notifier)
                  .loadNotifications(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required bool hasFilters}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                color: AppColors.primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters
                  ? 'No matching notifications'
                  : 'You\'re all caught up!',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilters
                  ? 'Try selecting another filter or clearing current filters.'
                  : 'Important order updates, delivery tracking, and promotions will appear here.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(
    NotificationEntity notification,
    NotificationController notifier,
  ) {
    if (!notification.isRead) {
      notifier.markAsRead(notification.id);
    }

    final data = notification.data;
    final orderId = data['order_id'] ?? data['orderId'];

    if (orderId != null && orderId.toString().isNotEmpty) {
      // Prompt user or navigate directly to orders
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification for Order #$orderId'),
          action: SnackBarAction(
            label: 'View Orders',
            onPressed: () {
              context.pushNamed(RouteNames.orders);
            },
          ),
        ),
      );
    } else {
      _showNotificationDetail(notification);
    }
  }

  void _showNotificationDetail(NotificationEntity notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    notification.notificationType.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                if (notification.createdAt != null)
                  Text(
                    '${notification.createdAt!.day}/${notification.createdAt!.month}/${notification.createdAt!.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              notification.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              notification.message,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Dismiss',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
