import '../entities/device_token_entity.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  /// Fetches notifications for current authenticated user.
  /// If [unreadOnly] is true, only unread notifications are returned.
  Future<List<NotificationEntity>> getNotifications({bool? unreadOnly});

  /// Fetches the count of unread notifications.
  Future<int> getUnreadCount();

  /// Marks a specific notification as read.
  Future<NotificationEntity> markAsRead(String notificationId);

  /// Marks all unread notifications as read. Returns the number of updated items.
  Future<int> markAllAsRead();

  /// Registers or updates an FCM/APNS device token for push notifications.
  Future<DeviceTokenEntity> registerDeviceToken({
    required String token,
    required DevicePlatform platform,
  });

  /// Deactivates a device token when user logs out or disables notifications.
  Future<void> unregisterDeviceToken(String deviceTokenId);
}
