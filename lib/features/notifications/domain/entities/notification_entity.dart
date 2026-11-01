import 'package:equatable/equatable.dart';

enum NotificationType {
  general('GENERAL', 'General'),
  order('ORDER', 'Orders'),
  payment('PAYMENT', 'Payments'),
  delivery('DELIVERY', 'Delivery'),
  promotion('PROMOTION', 'Promotions'),
  loyalty('LOYALTY', 'Loyalty');

  final String value;
  final String label;

  const NotificationType(this.value, this.label);

  static NotificationType fromString(String? type) {
    if (type == null) return NotificationType.general;
    final normalized = type.trim().toUpperCase();
    for (final t in NotificationType.values) {
      if (t.value == normalized) return t;
    }
    return NotificationType.general;
  }
}

class NotificationEntity extends Equatable {
  final String id;
  final NotificationType notificationType;
  final String title;
  final String message;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  const NotificationEntity({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.message,
    this.data = const {},
    this.isRead = false,
    this.readAt,
    this.createdAt,
  });

  NotificationEntity copyWith({
    String? id,
    NotificationType? notificationType,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      notificationType: notificationType ?? this.notificationType,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        notificationType,
        title,
        message,
        data,
        isRead,
        readAt,
        createdAt,
      ];
}
