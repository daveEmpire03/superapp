// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/order_entity.dart';

class OrderTimelineWidget extends StatelessWidget {
  final OrderEntity order;

  const OrderTimelineWidget({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    if (order.isCancelled) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.errorSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: AppColors.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                order.status == BackendOrderStatus.expired
                    ? 'This order expired before inventory confirmation.'
                    : 'This order was cancelled.',
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final steps = [
      _TimelineStep(
        title: 'Order Placed',
        subtitle: 'Confirmed & received by store',
        isCompleted: _stepIndex(order.status) >= 1,
        isCurrent: _stepIndex(order.status) == 1,
      ),
      _TimelineStep(
        title: 'Preparing Groceries',
        subtitle: 'Picked and packed at ${order.storeName}',
        isCompleted: _stepIndex(order.status) >= 2,
        isCurrent: _stepIndex(order.status) == 2,
      ),
      _TimelineStep(
        title: order.fulfilmentType == OrderFulfilmentType.pickup
            ? 'Ready for Pickup'
            : 'Out for Delivery',
        subtitle: order.fulfilmentType == OrderFulfilmentType.pickup
            ? 'Collect at customer service counter'
            : 'Rider is on the way to you',
        isCompleted: _stepIndex(order.status) >= 3,
        isCurrent: _stepIndex(order.status) == 3,
      ),
      _TimelineStep(
        title: order.fulfilmentType == OrderFulfilmentType.pickup
            ? 'Picked Up'
            : 'Delivered',
        subtitle: 'Order completed successfully',
        isCompleted: _stepIndex(order.status) >= 4,
        isCurrent: _stepIndex(order.status) == 4,
      ),
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: step.isCompleted
                        ? AppColors.primary
                        : (step.isCurrent
                            ? AppColors.primarySoft
                            : AppColors.surfaceElevated),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: step.isCompleted || step.isCurrent
                          ? AppColors.primary
                          : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: step.isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : (step.isCurrent
                            ? Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 38,
                    color: step.isCompleted
                        ? AppColors.primary
                        : AppColors.border,
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: step.isCompleted || step.isCurrent
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: step.isCompleted || step.isCurrent
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  static int _stepIndex(BackendOrderStatus status) {
    switch (status) {
      case BackendOrderStatus.pending:
      case BackendOrderStatus.confirmed:
        return 1;
      case BackendOrderStatus.preparing:
        return 2;
      case BackendOrderStatus.ready:
      case BackendOrderStatus.dispatched:
      case BackendOrderStatus.outForDelivery:
        return 3;
      case BackendOrderStatus.delivered:
        return 4;
      case BackendOrderStatus.cancelled:
      case BackendOrderStatus.expired:
        return 0;
    }
  }
}

class _TimelineStep {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isCurrent,
  });
}
