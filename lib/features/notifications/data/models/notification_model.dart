import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.notificationType,
    required super.title,
    required super.message,
    super.data,
    super.isRead,
    super.readAt,
    super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _requiredString(json['id'], field: 'id'),
      notificationType: NotificationType.fromString(
        _nullableString(json['notification_type']),
      ),
      title: _requiredString(json['title'], field: 'title'),
      message: _nullableString(json['message']) ?? '',
      data: _toMap(json['data']),
      isRead: _toBool(json['is_read']),
      readAt: _toDateTime(json['read_at']),
      createdAt: _toDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_type': notificationType.value,
      'title': title,
      'message': message,
      'data': data,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static String _requiredString(dynamic value, {required String field}) {
    if (value == null) {
      throw FormatException('Notification response missing required "$field".');
    }
    final parsed = value.toString().trim();
    if (parsed.isEmpty) {
      throw FormatException('Notification field "$field" cannot be empty.');
    }
    return parsed;
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final parsed = value.toString().trim();
    return parsed.isEmpty ? null : parsed;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value == 1 || value == '1' || value == 'true') return true;
    return false;
  }

  static Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const {};
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
