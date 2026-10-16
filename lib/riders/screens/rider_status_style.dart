import 'package:bokku_mart/core/constants/app_colors.dart';
import 'package:bokku_mart/riders/domain/entities/rider_job_entity.dart';
import 'package:flutter/material.dart';

extension DeliveryStatusStyle on DeliveryStatus {
  Color get color {
    switch (this) {
      case DeliveryStatus.pending:
      case DeliveryStatus.cancelled:
        return AppColors.textMuted;
      case DeliveryStatus.assigned:
        return AppColors.primary;
      case DeliveryStatus.accepted:
        return AppColors.primaryLight;
      case DeliveryStatus.pickedUp:
      case DeliveryStatus.outForDelivery:
        return AppColors.warning;
      case DeliveryStatus.delivered:
        return AppColors.success;
      case DeliveryStatus.rejected:
        return AppColors.error;
    }
  }

  Color get surface {
    switch (this) {
      case DeliveryStatus.pending:
      case DeliveryStatus.cancelled:
        return AppColors.surface;
      case DeliveryStatus.assigned:
      case DeliveryStatus.accepted:
        return AppColors.primarySoft;
      case DeliveryStatus.pickedUp:
      case DeliveryStatus.outForDelivery:
        return AppColors.warningSurface;
      case DeliveryStatus.delivered:
        return AppColors.successSurface;
      case DeliveryStatus.rejected:
        return AppColors.errorSurface;
    }
  }

  IconData get icon {
    switch (this) {
      case DeliveryStatus.pending:
        return Icons.hourglass_empty;
      case DeliveryStatus.assigned:
        return Icons.assignment_outlined;
      case DeliveryStatus.accepted:
        return Icons.check_circle_outline;
      case DeliveryStatus.pickedUp:
        return Icons.inventory_2_outlined;
      case DeliveryStatus.outForDelivery:
        return Icons.local_shipping_outlined;
      case DeliveryStatus.delivered:
        return Icons.done_all;
      case DeliveryStatus.rejected:
        return Icons.cancel_outlined;
      case DeliveryStatus.cancelled:
        return Icons.block;
    }
  }
}
