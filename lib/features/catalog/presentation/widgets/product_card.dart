import 'package:bokku_mart/features/cart/presentation/providers/cart_state_provider.dart';
import 'package:bokku_mart/core/providers/riverpod_ui.dart';
import 'package:bokku_mart/features/catalog/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/router/route_names.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final double width;

  const ProductCard({
    super.key,
    required this.product,
    this.width = 175,
  });

  static String? _normalizeId(Object? value) {
    if (value == null) {
      return null;
    }

    final normalized = value.toString().trim();

    if (normalized.isEmpty || normalized == '0' || normalized == 'null') {
      return null;
    }

    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.pushNamed(
              RouteNames.productDetail,
              pathParameters: {'id': product.id},
              extra: product,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      height: 130,
                      width: double.infinity,
                      color: AppColors.surfaceElevated,
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: AppColors.textMuted,
                            size: 40,
                          ),
                        ),
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                        ),
                      ),
                    ),
                  ),
                  if (product.badge != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (product.stockCount <= 0)
                    Positioned(
                      bottom: 6,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Out of stock',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else if (product.stockCount < 30)
                    Positioned(
                      bottom: 6,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Only ${product.stockCount} left',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand.toUpperCase(),
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.size,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                CurrencyFormatter.format(product.price),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              if (product.oldPrice != null)
                                Text(
                                  CurrencyFormatter.format(product.oldPrice!),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        RiverpodBuilder<CartState>(
      provider: cartStateProvider,
                          builder: (context, state) {
                            final inventoryId =
                                _normalizeId(product.inventoryId);
                            final storeId = _normalizeId(product.storeId);

                            if (state is CartLoaded) {
                              final matches = state.items.where((item) {
                                if (inventoryId != null) {
                                  return item.inventoryId == inventoryId;
                                }

                                return item.productId == product.id;
                              }).toList();

                              if (matches.isNotEmpty) {
                                final cartItem = matches.first;
                                final quantity = cartItem.quantity;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (quantity <= 1) {
                                            ProviderScope.containerOf(context, listen: false).read(cartStateProvider.notifier).add(
                                                  RemoveFromCartEvent(
                                                    cartItem.id,
                                                  ),
                                                );
                                            return;
                                          }

                                          ProviderScope.containerOf(context, listen: false).read(cartStateProvider.notifier).add(
                                                UpdateCartQuantityEvent(
                                                  cartItem.id,
                                                  quantity - 1,
                                                ),
                                              );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.remove,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: Text(
                                          '$quantity',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: cartItem.canIncrement
                                            ? () {
                                                ProviderScope.containerOf(context, listen: false).read(cartStateProvider.notifier).add(
                                                      UpdateCartQuantityEvent(
                                                        cartItem.id,
                                                        quantity + 1,
                                                      ),
                                                    );
                                              }
                                            : null,
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.add,
                                            size: 14,
                                            color: cartItem.canIncrement
                                                ? Colors.white
                                                : Colors.white54,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }

                            final canAdd = inventoryId != null &&
                                product.inStock &&
                                product.stockCount > 0;

                            return InkWell(
                              onTap: canAdd
                                  ? () {
                                      ProviderScope.containerOf(context, listen: false).read(cartStateProvider.notifier).add(
                                            AddToCartEvent(
                                              inventoryId: inventoryId,
                                              storeId: storeId,
                                              productName: product.name,
                                            ),
                                          );

                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${product.name} added to cart',
                                            ),
                                            duration:
                                                const Duration(seconds: 1),
                                            backgroundColor: AppColors.primary,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: canAdd
                                      ? AppColors.primarySurface
                                      : AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: canAdd
                                        ? AppColors.primaryLight.withValues(
                                            alpha: 0.3,
                                          )
                                        : AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      canAdd
                                          ? Icons.add
                                          : Icons.remove_shopping_cart_outlined,
                                      size: 14,
                                      color: canAdd
                                          ? AppColors.primary
                                          : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      canAdd ? 'Add' : 'Unavailable',
                                      style: TextStyle(
                                        color: canAdd
                                            ? AppColors.primary
                                            : AppColors.textMuted,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
