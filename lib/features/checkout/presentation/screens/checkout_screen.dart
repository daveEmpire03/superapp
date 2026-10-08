import 'package:bokku_mart/features/checkout/presentation/providers/checkout_state_provider.dart';
import 'package:bokku_mart/features/cart/presentation/providers/cart_state_provider.dart';
import 'package:bokku_mart/core/providers/riverpod_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/router/route_names.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../bloc/checkout_event.dart';
import '../bloc/checkout_state.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    ProviderScope.containerOf(context, listen: false).read(checkoutStateProvider.notifier).add(LoadCheckoutInitialDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return RiverpodListener<CheckoutState>(
      provider: checkoutStateProvider,
      listener: (context, state) {
        if (state is CheckoutOrderPlacedSuccess) {
          // Clear cart on successful order placement
          ProviderScope.containerOf(context, listen: false).read(cartStateProvider.notifier).add(const ClearCartEvent());
          context.goNamed(
            RouteNames.orderSuccess,
            extra: state.order,
          );
        } else if (state is CheckoutDataLoaded && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.accentRed),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Checkout',
              style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        body: RiverpodBuilder<CartState>(
      provider: cartStateProvider,
          builder: (context, cartState) {
            if (cartState is! CartLoaded || cartState.items.isEmpty) {
              return const Center(child: Text('No items in basket'));
            }

            return RiverpodBuilder<CheckoutState>(
      provider: checkoutStateProvider,
              builder: (context, checkoutState) {
                if (checkoutState is CheckoutLoading) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary));
                }

                if (checkoutState is! CheckoutDataLoaded) {
                  return const Center(
                      child: Text('Failed to load checkout settings'));
                }

                final isDelivery = checkoutState.deliveryMethod == 'delivery';

                // CartLoaded owns basket data only. Delivery fees and the final
                // payable total are authoritative checkout/order values and are
                // calculated by the backend when the order is created.
                final basketSubtotal = cartState.subtotal;

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Delivery or Pickup Toggle
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        ProviderScope.containerOf(context, listen: false).read(checkoutStateProvider.notifier).add(
                                            const SelectDeliveryMethodEvent(
                                                'delivery'));
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isDelivery
                                              ? Colors.white
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: isDelivery
                                              ? [
                                                  BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.05),
                                                      blurRadius: 4)
                                                ]
                                              : null,
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.delivery_dining,
                                                  size: 18,
                                                  color: isDelivery
                                                      ? AppColors.primary
                                                      : AppColors
                                                          .textSecondary),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Doorstep Delivery',
                                                style: TextStyle(
                                                  fontWeight: isDelivery
                                                      ? FontWeight.w700
                                                      : FontWeight.w600,
                                                  color: isDelivery
                                                      ? AppColors.primary
                                                      : AppColors.textSecondary,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        ProviderScope.containerOf(context, listen: false).read(checkoutStateProvider.notifier).add(
                                            const SelectDeliveryMethodEvent(
                                                'pickup'));
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          color: !isDelivery
                                              ? Colors.white
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: !isDelivery
                                              ? [
                                                  BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.05),
                                                      blurRadius: 4)
                                                ]
                                              : null,
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.store,
                                                  size: 18,
                                                  color: !isDelivery
                                                      ? AppColors.primary
                                                      : AppColors
                                                          .textSecondary),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Store Pickup (FREE)',
                                                style: TextStyle(
                                                  fontWeight: !isDelivery
                                                      ? FontWeight.w700
                                                      : FontWeight.w600,
                                                  color: !isDelivery
                                                      ? AppColors.primary
                                                      : AppColors.textSecondary,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 2. Address / Store Selection
                            if (isDelivery) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Delivery Address',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800)),
                                  TextButton(
                                      onPressed: () {},
                                      child: const Text('+ Add New',
                                          style: TextStyle(
                                              color: AppColors.primary))),
                                ],
                              ),
                              ...checkoutState.addresses.map((addr) {
                                final isSelected =
                                    checkoutState.selectedAddress?.id ==
                                        addr.id;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: RadioListTile<String>(
                                    value: addr.id,
                                    groupValue:
                                        checkoutState.selectedAddress?.id,
                                    activeColor: AppColors.primary,
                                    onChanged: (_) {
                                      context
                                          .read<CheckoutBloc>()
                                          .add(SelectAddressEvent(addr));
                                    },
                                    title: Text(
                                        '${addr.label} • ${addr.fullName}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13)),
                                    subtitle: Text(addr.fullDisplayAddress,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary)),
                                  ),
                                );
                              }),
                            ] else ...[
                              const Text('Select Pickup Store Hub',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 8),
                              ...checkoutState.stores.map((store) {
                                final isSelected =
                                    checkoutState.selectedStore?.id == store.id;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: RadioListTile<String>(
                                    value: store.id,
                                    groupValue: checkoutState.selectedStore?.id,
                                    activeColor: AppColors.primary,
                                    onChanged: (_) {
                                      context
                                          .read<CheckoutBloc>()
                                          .add(SelectPickupStoreEvent(store));
                                    },
                                    title: Text(store.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13)),
                                    subtitle: Text(
                                        '${store.address} • ${store.distance}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary)),
                                  ),
                                );
                              }),
                            ],

                            const SizedBox(height: 16),

                            // 3. Payment Method
                            const Text('Payment Method',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                children: [
                                  RadioListTile<String>(
                                    value:
                                        'Instant Card (Paystack/Flutterwave)',
                                    groupValue:
                                        checkoutState.selectedPaymentMethod,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) {
                                      context
                                          .read<CheckoutBloc>()
                                          .add(SelectPaymentMethodEvent(val!));
                                    },
                                    title: const Text(
                                        'Debit / Credit Card (Instant)',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13)),
                                    subtitle: const Text(
                                        'Mastercard, Visa, Verve accepted',
                                        style: TextStyle(fontSize: 11)),
                                  ),
                                  const Divider(height: 1),
                                  RadioListTile<String>(
                                    value: 'Instant Bank Transfer',
                                    groupValue:
                                        checkoutState.selectedPaymentMethod,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) {
                                      context
                                          .read<CheckoutBloc>()
                                          .add(SelectPaymentMethodEvent(val!));
                                    },
                                    title: const Text(
                                        'Direct Bank Transfer (Virtual Account)',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13)),
                                    subtitle: const Text(
                                        'Auto-verified in 30 seconds',
                                        style: TextStyle(fontSize: 11)),
                                  ),
                                  const Divider(height: 1),
                                  RadioListTile<String>(
                                    value: 'Bokku Wallet',
                                    groupValue:
                                        checkoutState.selectedPaymentMethod,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) {
                                      context
                                          .read<CheckoutBloc>()
                                          .add(SelectPaymentMethodEvent(val!));
                                    },
                                    title: const Text(
                                        'Bokku Mart Wallet (Balance: ₦18,500)',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13)),
                                    subtitle: const Text(
                                        '1-click checkout with cashback earnings',
                                        style: TextStyle(fontSize: 11)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Sticky Order Summary & Submit Button
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border:
                            Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Basket Subtotal',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16)),
                                Text(
                                  CurrencyFormatter.format(basketSubtotal),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20,
                                      color: AppColors.primaryDark),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Delivery fee and final total are confirmed by the server when the order is placed.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: checkoutState.isSubmitting
                                    ? null
                                    : () {
                                        ProviderScope.containerOf(context, listen: false).read(checkoutStateProvider.notifier).add(
                                              SubmitPlaceOrderEvent(
                                                items: cartState.items,
                                                subtotal: cartState.subtotal,
                                                discount: 0,
                                                // Legacy event fields. The backend remains
                                                // authoritative for delivery fee and final total.
                                                deliveryFee: 0.0,
                                                total: basketSubtotal,
                                              ),
                                            );
                                      },
                                child: checkoutState.isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : const Text('Place Order'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
