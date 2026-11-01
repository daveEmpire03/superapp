// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationItemCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;

  const NotificationItemCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final typeConfig = _getTypeConfig(notification.notificationType);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.primarySoft.withOpacity(0.35)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? AppColors.primaryLight.withOpacity(0.4)
                : AppColors.border.withOpacity(0.8),
            width: isUnread ? 1.2 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Type Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: typeConfig.backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: typeConfig.color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                typeConfig.icon,
                color: typeConfig.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: typeConfig.color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          notification.notificationType.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: typeConfig.color,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(notification.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  static _NotificationTypeConfig _getTypeConfig(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return const _NotificationTypeConfig(
          icon: Icons.local_mall_outlined,
          color: AppColors.primary,
          backgroundColor: AppColors.primarySoft,
        );
      case NotificationType.delivery:
        return const _NotificationTypeConfig(
          icon: Icons.delivery_dining_rounded,
          color: Color(0xFF0284C7),
          backgroundColor: Color(0xFFE0F2FE),
        );
      case NotificationType.payment:
        return const _NotificationTypeConfig(
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.success,
          backgroundColor: AppColors.successSurface,
        );
      case NotificationType.promotion:
        return const _NotificationTypeConfig(
          icon: Icons.local_offer_outlined,
          color: AppColors.discount,
          backgroundColor: Color(0xFFFEE2E2),
        );
      case NotificationType.loyalty:
        return const _NotificationTypeConfig(
          icon: Icons.stars_rounded,
          color: Color(0xFFD97706),
          backgroundColor: Color(0xFFFEF3C7),
        );
      case NotificationType.general:
        return const _NotificationTypeConfig(
          icon: Icons.notifications_none_rounded,
          color: AppColors.textSecondary,
          backgroundColor: AppColors.surface,
        );
    }
  }
}

class _NotificationTypeConfig {
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _NotificationTypeConfig({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}
