import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/router/route_names.dart';
import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart';
import '../bloc/checkout_state.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CheckoutBloc>().add(LoadCheckoutInitialDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Supermarket Orders',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          // Predefined realistic past order list
          final orders = [
            {
              'id': 'order-1',
              'number': 'BM-84920',
              'date': 'Today, 10:24 AM',
              'status': 'Out for Delivery 🛵',
              'items':
                  'Golden Penny Spaghetti (3x), Peak Milk (1x), Tatashey (1x)',
              'total': 15550.0,
              'active': true,
            },
            {
              'id': 'order-2',
              'number': 'BM-79341',
              'date': '22 Sep 2026, 4:15 PM',
              'status': 'Delivered',
              'items': 'Mama Gold Rice 5kg (1x), Kings Cooking Oil 3L (1x)',
              'total': 27800.0,
              'active': false,
            },
            {
              'id': 'order-3',
              'number': 'BM-71029',
              'date': '14 Sep 2026, 11:30 AM',
              'status': 'Delivered (Store Pickup)',
              'items': 'Ripe Plantain Bunch (2x), Sunlight Detergent (1x)',
              'total': 13600.0,
              'active': false,
            },
          ];

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final o = orders[index];
              final isActive = o['active'] as bool;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive ? AppColors.primaryLight : AppColors.border,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          o['number'] as String,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primarySurface
                                : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            o['status'] as String,
                            style: TextStyle(
                              color: isActive
                                  ? AppColors.primaryDark
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      o['date'] as String,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      o['items'] as String,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          CurrencyFormatter.format(o['total'] as num),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppColors.primaryDark),
                        ),
                        if (isActive)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              textStyle: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            onPressed: () {
                              context.pushNamed(
                                RouteNames.orderTracking,
                                pathParameters: {'id': o['id'] as String},
                              );
                            },
                            child: const Text('Live Track'),
                          )
                        else
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              textStyle: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Re-order added to your basket!')),
                              );
                            },
                            child: const Text('Re-order'),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
