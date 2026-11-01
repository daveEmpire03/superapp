// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/order_entity.dart';

class OrderStatusBadge extends StatelessWidget {
  final BackendOrderStatus status;

  const OrderStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getStyle(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: style.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            style.icon,
            size: 13,
            color: style.color,
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: style.color,
            ),
          ),
        ],
      ),
    );
  }

  static _StatusStyle _getStyle(BackendOrderStatus status) {
    switch (status) {
      case BackendOrderStatus.pending:
        return const _StatusStyle(
          color: Color(0xFFD97706),
          backgroundColor: Color(0xFFFEF3C7),
          borderColor: Color(0xFFFDE68A),
          icon: Icons.hourglass_empty_rounded,
        );
      case BackendOrderStatus.confirmed:
        return const _StatusStyle(
          color: AppColors.primary,
          backgroundColor: AppColors.primarySoft,
          borderColor: Color(0xFFDDD6FE),
          icon: Icons.check_circle_outline_rounded,
        );
      case BackendOrderStatus.preparing:
        return const _StatusStyle(
          color: Color(0xFF4338CA),
          backgroundColor: Color(0xFFEEF2FF),
          borderColor: Color(0xFFE0E7FF),
          icon: Icons.inventory_2_outlined,
        );
      case BackendOrderStatus.ready:
        return const _StatusStyle(
          color: Color(0xFF0F766E),
          backgroundColor: Color(0xFFCCFBF1),
          borderColor: Color(0xFF99F6E4),
          icon: Icons.storefront_outlined,
        );
      case BackendOrderStatus.dispatched:
      case BackendOrderStatus.outForDelivery:
        return const _StatusStyle(
          color: Color(0xFF0284C7),
          backgroundColor: Color(0xFFE0F2FE),
          borderColor: Color(0xFFBAE6FD),
          icon: Icons.delivery_dining_rounded,
        );
      case BackendOrderStatus.delivered:
        return const _StatusStyle(
          color: AppColors.success,
          backgroundColor: AppColors.successSurface,
          borderColor: Color(0xFFBBF7D0),
          icon: Icons.verified_rounded,
        );
      case BackendOrderStatus.cancelled:
      case BackendOrderStatus.expired:
        return const _StatusStyle(
          color: AppColors.error,
          backgroundColor: AppColors.errorSurface,
          borderColor: Color(0xFFFECACA),
          icon: Icons.cancel_outlined,
        );
    }
  }
}

class _StatusStyle {
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;

  const _StatusStyle({
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
  });
}
