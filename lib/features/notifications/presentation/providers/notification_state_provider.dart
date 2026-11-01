import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/device_token_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../bloc/notification_state.dart';

final notificationStateProvider =
    NotifierProvider<NotificationController, NotificationState>(
  NotificationController.new,
);

final unreadNotificationCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificationStateProvider);
  if (state is NotificationLoaded) {
    return state.unreadCount;
  }
  return 0;
});

class NotificationController extends Notifier<NotificationState> {
  NotificationRepository get notificationRepository =>
      ref.read(notificationRepositoryProvider);

  @override
  NotificationState build() => const NotificationInitial();

  Future<void> loadNotifications({
    bool unreadOnly = false,
    bool silent = false,
  }) async {
    final currentState = state;
    if (!silent || currentState is! NotificationLoaded) {
      state = const NotificationLoading();
    }

    try {
      final notifications = await notificationRepository.getNotifications();
      final unreadCount = await notificationRepository.getUnreadCount();

      state = NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
        unreadOnlyFilter: unreadOnly,
        selectedTypeFilter: currentState is NotificationLoaded
            ? currentState.selectedTypeFilter
            : null,
      );
    } catch (error) {
      final cached = currentState is NotificationLoaded
          ? currentState.notifications
          : <NotificationEntity>[];
      state = NotificationError(
        _errorMessage(error),
        cachedNotifications: cached,
      );
    }
  }

  Future<void> refresh() async {
    await loadNotifications(silent: true);
  }

  Future<void> markAsRead(String notificationId) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    final targetIndex = currentState.notifications.indexWhere(
      (n) => n.id == notificationId,
    );
    if (targetIndex == -1) return;

    final target = currentState.notifications[targetIndex];
    if (target.isRead) return; // already read

    // Optimistically mark as read
    final updatedNotifications = List<NotificationEntity>.from(
      currentState.notifications,
    );
    updatedNotifications[targetIndex] = target.copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );

    final newUnreadCount = (currentState.unreadCount - 1).clamp(0, 999999);

    state = currentState.copyWith(
      notifications: updatedNotifications,
      unreadCount: newUnreadCount,
    );

    try {
      await notificationRepository.markAsRead(notificationId);
    } catch (_) {
      // Background retry or keep optimistic state to avoid UI flicker
    }
  }

  Future<void> markAllAsRead() async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;
    if (currentState.unreadCount == 0) return;

    final now = DateTime.now();
    final updatedNotifications = currentState.notifications.map((n) {
      if (!n.isRead) {
        return n.copyWith(isRead: true, readAt: now);
      }
      return n;
    }).toList();

    state = currentState.copyWith(
      notifications: updatedNotifications,
      unreadCount: 0,
    );

    try {
      await notificationRepository.markAllAsRead();
    } catch (_) {
      // Re-sync with server if needed
      await refresh();
    }
  }

  void filterByType(NotificationType? type) {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    if (currentState.selectedTypeFilter == type) {
      state = currentState.copyWith(clearTypeFilter: true);
    } else {
      state = currentState.copyWith(selectedTypeFilter: type);
    }
  }

  void toggleUnreadOnly() {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    state = currentState.copyWith(
      unreadOnlyFilter: !currentState.unreadOnlyFilter,
    );
  }

  Future<DeviceTokenEntity?> registerDeviceToken({
    required String token,
    required DevicePlatform platform,
  }) async {
    try {
      return await notificationRepository.registerDeviceToken(
        token: token,
        platform: platform,
      );
    } catch (_) {
      return null;
    }
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
