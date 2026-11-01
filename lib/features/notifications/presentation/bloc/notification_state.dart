import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final NotificationType? selectedTypeFilter;
  final bool unreadOnlyFilter;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
    this.selectedTypeFilter,
    this.unreadOnlyFilter = false,
  });

  bool get isEmpty => notifications.isEmpty;
  bool get isNotEmpty => notifications.isNotEmpty;
  bool get hasUnread => unreadCount > 0;

  List<NotificationEntity> get filteredNotifications {
    var list = notifications;
    if (unreadOnlyFilter) {
      list = list.where((n) => !n.isRead).toList();
    }
    if (selectedTypeFilter != null) {
      list = list.where((n) => n.notificationType == selectedTypeFilter).toList();
    }
    return list;
  }

  NotificationLoaded copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    NotificationType? selectedTypeFilter,
    bool clearTypeFilter = false,
    bool? unreadOnlyFilter,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      selectedTypeFilter: clearTypeFilter
          ? null
          : (selectedTypeFilter ?? this.selectedTypeFilter),
      unreadOnlyFilter: unreadOnlyFilter ?? this.unreadOnlyFilter,
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        unreadCount,
        selectedTypeFilter,
        unreadOnlyFilter,
      ];
}

class NotificationError extends NotificationState {
  final String message;
  final List<NotificationEntity> cachedNotifications;

  const NotificationError(
    this.message, {
    this.cachedNotifications = const [],
  });

  @override
  List<Object?> get props => [message, cachedNotifications];
}
