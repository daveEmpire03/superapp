import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/order_entity.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderEntity order;

  const OrderTrackingScreen({super.key, required this.order});

  Widget _buildStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.primary
                    : (isCurrent
                        ? AppColors.secondary
                        : AppColors.surfaceElevated),
                border: Border.all(
                  color: isCompleted || isCurrent
                      ? Colors.transparent
                      : AppColors.border,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : (isCurrent
                        ? const Icon(Icons.circle, size: 8, color: Colors.white)
                        : null),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: isCompleted ? AppColors.primary : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: isCurrent || isCompleted
                      ? FontWeight.w700
                      : FontWeight.w500,
                  fontSize: 14,
                  color: isCurrent || isCompleted
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Track ${order.orderNumber}',
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Estimated Delivery',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(order.estimatedArrival,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('ON TIME',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Rider Card if available
            if (order.rider != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.primarySurface,
                      radius: 24,
                      child: Icon(Icons.person,
                          color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.rider!.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 14)),
                          Text(order.rider!.vehicle,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone, color: AppColors.primary),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Step Progress Timeline
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Timeline',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 20),
                  _buildStep(
                    title: 'Order Confirmed',
                    subtitle:
                        'Your payment was confirmed and sent to Bokku Mart hub.',
                    isCompleted: true,
                    isCurrent: false,
                    isLast: false,
                  ),
                  _buildStep(
                    title: 'Freshly Picked & Packed',
                    subtitle:
                        'Our supermarket staff handpicked and quality-checked your items.',
                    isCompleted: true,
                    isCurrent: false,
                    isLast: false,
                  ),
                  _buildStep(
                    title: 'Dispatched with Dispatch Rider',
                    subtitle:
                        'Rider is on the way with your insulated grocery box.',
                    isCompleted: false,
                    isCurrent: true,
                    isLast: false,
                  ),
                  _buildStep(
                    title: 'Delivered to Doorstep',
                    subtitle: 'Enjoy your fresh Bokku groceries!',
                    isCompleted: false,
                    isCurrent: false,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
