import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Shopping Basket',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.items.isNotEmpty) {
                return TextButton(
                  onPressed: () {
                    _showClearCartDialog(context);
                  },
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      color: AppColors.accentRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is CartError) {
            return _CartErrorView(
              message: state.message,
              onRetry: () {
                context.read<CartBloc>().add(
                      const LoadCartEvent(),
                    );
              },
            );
          }

          if (state is! CartLoaded || state.items.isEmpty) {
            return const _EmptyCartView();
          }

          return _LoadedCartView(
            state: state,
          );
        },
      ),
    );
  }

  void _showClearCartDialog(
    BuildContext context,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Clear Basket?',
          ),
          content: const Text(
            'Are you sure you want to remove all items from your basket?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                context.read<CartBloc>().add(
                      const ClearCartEvent(),
                    );
              },
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: AppColors.accentRed,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LoadedCartView extends StatelessWidget {
  final CartLoaded state;

  const _LoadedCartView({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (state.storeName != null)
          _StoreBanner(
            storeName: state.storeName!,
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              24,
            ),
            itemCount: state.items.length,
            separatorBuilder: (_, __) {
              return const SizedBox(
                height: 12,
              );
            },
            itemBuilder: (context, index) {
              final item = state.items[index];

              return _CartItemCard(
                item: item,
              );
            },
          ),
        ),
        _CartSummary(
          state: state,
        ),
      ],
    );
  }
}

class _StoreBanner extends StatelessWidget {
  final String storeName;

  const _StoreBanner({
    required this.storeName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        0,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.storefront_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Basket store',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemEntity item;

  const _CartItemCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ProductImage(
            imageUrl: item.productImageUrl,
          ),
          const SizedBox(
            width: 14,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (item.sku.isNotEmpty) ...[
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    'SKU: ${item.sku}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(
                  height: 8,
                ),
                Text(
                  CurrencyFormatter.format(
                    item.unitPrice,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.primaryDark,
                  ),
                ),
                if (item.quantity > 1) ...[
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    'Total: ${CurrencyFormatter.format(item.lineTotal)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (item.availableQuantity <= 5) ...[
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    item.availableQuantity <= 0
                        ? 'Out of stock'
                        : '${item.availableQuantity} available',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.accentRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          _QuantityStepper(
            item: item,
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;

  const _ProductImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();

    if (url == null || url.isEmpty) {
      return _placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: url,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        placeholder: (_, __) {
          return _placeholder();
        },
        errorWidget: (_, __, ___) {
          return _placeholder();
        },
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final CartItemEntity item;

  const _QuantityStepper({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: item.quantity <= 1 ? 'Remove item' : 'Decrease quantity',
            icon: Icon(
              item.quantity <= 1 ? Icons.delete_outline : Icons.remove,
              size: 15,
              color: item.quantity <= 1
                  ? AppColors.accentRed
                  : AppColors.textPrimary,
            ),
            onPressed: () {
              context.read<CartBloc>().add(
                    UpdateCartQuantityEvent(
                      item.id,
                      item.quantity - 1,
                    ),
                  );
            },
          ),
          Text(
            '${item.quantity}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: item.canIncrement
                ? 'Increase quantity'
                : 'Maximum available stock reached',
            icon: Icon(
              Icons.add,
              size: 15,
              color: item.canIncrement
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
            onPressed: item.canIncrement
                ? () {
                    context.read<CartBloc>().add(
                          UpdateCartQuantityEvent(
                            item.id,
                            item.quantity + 1,
                          ),
                        );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final CartLoaded state;

  const _CartSummary({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(
              0,
              -4,
            ),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(
                    state.subtotal,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
                SizedBox(
                  width: 6,
                ),
                Expanded(
                  child: Text(
                    'Delivery, discounts and other fees are calculated at checkout.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pushNamed(
                    RouteNames.checkout,
                  );
                },
                child: Text(
                  'Checkout (${state.totalItemCount} ${state.totalItemCount == 1 ? 'item' : 'items'})',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.shopping_basket_outlined,
                  size: 54,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Your Basket is Empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              'Explore our selection of groceries, drinks, fresh food and household products.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
              onPressed: () {
                context.goNamed(
                  RouteNames.home,
                );
              },
              child: const Text(
                'Browse Products Now',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CartErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 52,
              color: AppColors.accentRed,
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              'Unable to load your basket',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
