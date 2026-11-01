import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/device_token_model.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({bool? unreadOnly});

  Future<int> getUnreadCount();

  Future<NotificationModel> markAsRead(String notificationId);

  Future<int> markAllAsRead();

  Future<DeviceTokenModel> registerDeviceToken({
    required String token,
    required String platform,
  });

  Future<void> unregisterDeviceToken(String deviceTokenId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient dioClient;

  NotificationRemoteDataSourceImpl({
    required this.dioClient,
  });

  @override
  Future<List<NotificationModel>> getNotifications({bool? unreadOnly}) async {
    final queryParams = <String, dynamic>{};
    if (unreadOnly == true) {
      queryParams['unread'] = '1';
    }

    final response = await dioClient.get<dynamic>(
      ApiEndpoints.notifications,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    return _parseNotificationList(response.data);
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await dioClient.get<dynamic>(
        ApiEndpoints.notificationUnreadCount,
      );

      final data = response.data;
      if (data is Map) {
        final count = data['unread_count'] ?? data['count'];
        if (count is num) {
          return count.toInt();
        }
      }
      return 0;
    } catch (_) {
      // Fallback: fetch unread notifications count
      try {
        final unreadList = await getNotifications(unreadOnly: true);
        return unreadList.length;
      } catch (_) {
        return 0;
      }
    }
  }

  @override
  Future<NotificationModel> markAsRead(String notificationId) async {
    final normalizedId = notificationId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError('notificationId cannot be empty.');
    }

    final response = await dioClient.patch<dynamic>(
      ApiEndpoints.markNotificationRead(normalizedId),
    );

    final data = response.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final item = map['data'] is Map ? Map<String, dynamic>.from(map['data']) : map;
      return NotificationModel.fromJson(item);
    }

    throw const FormatException('Invalid response when marking notification as read.');
  }

  @override
  Future<int> markAllAsRead() async {
    final response = await dioClient.patch<dynamic>(
      ApiEndpoints.readAllNotifications,
    );

    final data = response.data;
    if (data is Map) {
      final updated = data['updated'] ?? data['count'];
      if (updated is num) {
        return updated.toInt();
      }
    }
    return 0;
  }

  @override
  Future<DeviceTokenModel> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      throw ArgumentError('token cannot be empty.');
    }

    final response = await dioClient.post<dynamic>(
      ApiEndpoints.notificationDevices,
      data: {
        'token': normalizedToken,
        'platform': platform.trim().toUpperCase(),
      },
    );

    final data = response.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final item = map['data'] is Map ? Map<String, dynamic>.from(map['data']) : map;
      return DeviceTokenModel.fromJson(item);
    }

    throw const FormatException('Invalid response when registering device token.');
  }

  @override
  Future<void> unregisterDeviceToken(String deviceTokenId) async {
    final normalizedId = deviceTokenId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError('deviceTokenId cannot be empty.');
    }

    await dioClient.delete<dynamic>(
      ApiEndpoints.notificationDevice(normalizedId),
    );
  }

  List<NotificationModel> _parseNotificationList(dynamic data) {
    final items = _extractList(data);
    return items
        .whereType<Map>()
        .map(
          (item) => NotificationModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final results = map['results'] ?? map['data'];
      if (results is List) return results;
    }

    return const [];
  }
}
