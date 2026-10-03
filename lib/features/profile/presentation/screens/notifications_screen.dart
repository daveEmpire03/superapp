// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  final List<Map<String, String>> _notifications = const [
    {
      'title': 'Order BM-84920 is out for delivery! 🛵',
      'message':
          'Rider Babatunde has picked up your fresh groceries and is en route to Admiralty Way, Lekki. ETA: 18 mins.',
      'time': '8 mins ago',
      'isNew': 'true',
    },
    {
      'title': 'Weekend Deals Are Live! 🔥',
      'message':
          'Save up to 25% on Mama Gold Rice, Golden Penny Pasta, and fresh market peppers this weekend.',
      'time': '2 hours ago',
      'isNew': 'true',
    },
    {
      'title': 'Price Drop Alert: Kings Vegetable Oil 3L',
      'message':
          'Devon King’s Cooking Oil 3L dropped from ₦9,600 to ₦8,400. Stock up today before stocks deplete!',
      'time': 'Yesterday',
      'isNew': 'false',
    },
    {
      'title': 'Your Bokku Wallet was credited ₦5,000',
      'message':
          'Loyalty cashback reward for your 5th supermarket purchase this month has been added to your balance.',
      'time': '3 days ago',
      'isNew': 'false',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final n = _notifications[index];
          final isNew = n['isNew'] == 'true';

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isNew
                    ? AppColors.primaryLight.withOpacity(0.5)
                    : AppColors.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isNew
                        ? AppColors.primarySurface
                        : AppColors.surfaceElevated,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isNew
                        ? Icons.notifications_active
                        : Icons.notifications_none,
                    color: isNew ? AppColors.primary : AppColors.textMuted,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n['title']!,
                        style: TextStyle(
                          fontWeight: isNew ? FontWeight.w800 : FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n['message']!,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        n['time']!,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
