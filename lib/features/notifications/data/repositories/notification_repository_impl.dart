import '../../domain/entities/device_token_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<NotificationEntity>> getNotifications({bool? unreadOnly}) {
    return remoteDataSource.getNotifications(unreadOnly: unreadOnly);
  }

  @override
  Future<int> getUnreadCount() {
    return remoteDataSource.getUnreadCount();
  }

  @override
  Future<NotificationEntity> markAsRead(String notificationId) {
    return remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<int> markAllAsRead() {
    return remoteDataSource.markAllAsRead();
  }

  @override
  Future<DeviceTokenEntity> registerDeviceToken({
    required String token,
    required DevicePlatform platform,
  }) {
    return remoteDataSource.registerDeviceToken(
      token: token,
      platform: platform.value,
    );
  }

  @override
  Future<void> unregisterDeviceToken(String deviceTokenId) {
    return remoteDataSource.unregisterDeviceToken(deviceTokenId);
  }
}
