import 'package:bokku_mart/features/stores/presentation/providers/store_state_provider.dart';
import 'package:bokku_mart/features/catalog/presentation/providers/product_state_provider.dart';
import 'package:bokku_mart/core/providers/riverpod_ui.dart';
import 'package:bokku_mart/features/catalog/presentation/bloc/product_event.dart';
import 'package:bokku_mart/features/catalog/presentation/bloc/product_state.dart';
import 'package:bokku_mart/features/catalog/presentation/widgets/category_chip.dart';
import 'package:bokku_mart/features/catalog/presentation/widgets/product_card.dart';
import 'package:bokku_mart/features/stores/presentation/bloc/store_state.dart';
import 'package:bokku_mart/features/stores/presentation/widgets/store_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RiverpodListener<StoreState>(
      provider: storeStateProvider,
      listenWhen: (previous, current) {
        if (current is! StoreLoaded) {
          return false;
        }

        final currentStoreId = current.selectedStore?.id;

        if (currentStoreId == null) {
          return false;
        }

        if (previous is StoreLoaded) {
          return previous.selectedStore?.id != currentStoreId;
        }

        if (previous is StoreLocationLoading) {
          return previous.selectedStore?.id != currentStoreId;
        }

        // Initial catalog loading is handled
        // during app startup.
        return false;
      },
      listener: (context, state) {
        if (state is! StoreLoaded) {
          return;
        }

        final storeId = state.selectedStore?.id;

        if (storeId == null) {
          return;
        }

        final productBloc = ProviderScope.containerOf(context, listen: false).read(productStateProvider.notifier);

        if (productBloc.selectedStoreId == storeId) {
          return;
        }

        productBloc.add(
          LoadCatalogEvent(
            storeId: storeId,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              final storeState = ProviderScope.containerOf(context, listen: false).read(storeStateProvider.notifier).state;

              String? storeId;

              if (storeState is StoreLoaded) {
                storeId = storeState.selectedStore?.id;
              } else if (storeState is StoreLocationLoading) {
                storeId = storeState.selectedStore?.id;
              }

              final productBloc = ProviderScope.containerOf(context, listen: false).read(productStateProvider.notifier);

              productBloc.add(
                LoadCatalogEvent(
                  storeId: storeId ?? productBloc.selectedStoreId,
                ),
              );

              await productBloc.stream.firstWhere(
                (state) => state is ProductLoaded || state is ProductError,
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // -----------------------------------------------------------
                // Header
                // -----------------------------------------------------------

                SliverToBoxAdapter(
                  child: AppSlideIn(
                    direction: SlideDirection.fromTop,
                    duration: const Duration(milliseconds: 320),
                    distance: 0.06,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        12,
                        16,
                        18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bokku Mart',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      'Shop groceries from your preferred store',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Notifications',
                                onPressed: () {
                                  context.pushNamed(
                                    RouteNames.notifications,
                                  );
                                },
                                icon: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          const Text(
                            'Store',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          const StoreSelector(),
                          const SizedBox(
                            height: 8,
                          ),
                          RiverpodBuilder<StoreState>(
      provider: storeStateProvider,
                            builder: (context, state) {
                              final hasStore = state is StoreLoaded &&
                                  state.selectedStore?.id != null;

                              final isLocating = state is StoreLocationLoading;

                              Widget hintWidget;
                              if (isLocating) {
                                hintWidget = const _StoreHint(
                                  key: ValueKey('locating'),
                                  icon: Icons.location_searching_rounded,
                                  text:
                                      'Checking your location to help sort stores by distance...',
                                );
                              } else if (hasStore) {
                                hintWidget = const _StoreHint(
                                  key: ValueKey('has-store'),
                                  icon: Icons.storefront_rounded,
                                  text:
                                      'Product availability and pricing are shown for the selected store.',
                                );
                              } else {
                                hintWidget = const _StoreHint(
                                  key: ValueKey('no-store'),
                                  icon: Icons.storefront_outlined,
                                  text:
                                      'Choose a store to view its available products.',
                                );
                              }

                              return AnimatedSwitcher(
                                duration: const Duration(
                                  milliseconds: 250,
                                ),
                                child: hintWidget,
                              );
                            },
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          GestureDetector(
                            onTap: () {
                              context.pushNamed(
                                RouteNames.search,
                              );
                            },
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(
                                  14,
                                ),
                                border: Border.all(
                                  color: AppColors.border,
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    color: AppColors.textMuted,
                                    size: 22,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppStrings.searchHint,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: AppColors.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 22,
                  ),
                ),

                // -----------------------------------------------------------
                // Categories
                // -----------------------------------------------------------

                RiverpodBuilder<ProductState>(
      provider: productStateProvider,
                  builder: (context, state) {
                    if (state is! ProductLoaded || state.categories.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: SizedBox.shrink(),
                      );
                    }

                    return SliverToBoxAdapter(
                      child: AppSlideIn(
                        delay: const Duration(milliseconds: 60),
                        duration: const Duration(milliseconds: 300),
                        direction: SlideDirection.fromBottom,
                        distance: 0.08,
                        curve: Curves.easeOutCubic,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Categories',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.goNamed(
                                        RouteNames.categories,
                                      );
                                    },
                                    child: const Text(
                                      'View All',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              height: 44,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemCount: state.categories.length,
                                separatorBuilder: (_, __) => const SizedBox(
                                  width: 8,
                                ),
                                itemBuilder: (
                                  context,
                                  index,
                                ) {
                                  final category = state.categories[index];

                                  return CategoryChip(
                                    category: category,
                                    isSelected:
                                        state.selectedCategory == category.id,
                                    onTap: () {
                                      ProviderScope.containerOf(context, listen: false).read(productStateProvider.notifier).add(
                                            FilterByCategoryEvent(
                                              category.id,
                                            ),
                                          );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // -----------------------------------------------------------
                // Deals
                // -----------------------------------------------------------

                RiverpodBuilder<ProductState>(
      provider: productStateProvider,
                  builder: (context, state) {
                    if (state is! ProductLoaded || state.deals.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: SizedBox.shrink(),
                      );
                    }

                    return SliverToBoxAdapter(
                      child: AppSlideIn(
                        delay: const Duration(milliseconds: 100),
                        duration: const Duration(milliseconds: 320),
                        direction: SlideDirection.fromBottom,
                        distance: 0.08,
                        curve: Curves.easeOutCubic,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 26,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Deals',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.goNamed(
                                          RouteNames.deals,
                                        );
                                      },
                                      child: const Text(
                                        'View All',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 250,
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: state.deals.length,
                                  separatorBuilder: (_, __) => const SizedBox(
                                    width: 12,
                                  ),
                                  itemBuilder: (
                                    context,
                                    index,
                                  ) {
                                    return ProductCard(
                                      product: state.deals[index],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 26,
                  ),
                ),

                // -----------------------------------------------------------
                // Products
                // -----------------------------------------------------------

                RiverpodBuilder<ProductState>(
      provider: productStateProvider,
                  builder: (context, state) {
                    if (state is ProductLoading) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }

                    if (state is ProductError) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _CatalogError(
                          message: state.message,
                          onRetry: () {
                            final bloc = ProviderScope.containerOf(context, listen: false).read(productStateProvider.notifier);

                            bloc.add(
                              LoadCatalogEvent(
                                storeId: bloc.selectedStoreId,
                              ),
                            );
                          },
                        ),
                      );
                    }

                    if (state is ProductLoaded) {
                      final products = state.filteredProducts;

                      if (products.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyCatalog(
                            categorySelected: state.selectedCategory != null,
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        sliver: SliverMainAxisGroup(
                          slivers: [
                            SliverToBoxAdapter(
                              child: AppFadeIn(
                                duration: const Duration(milliseconds: 250),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          state.selectedCategory != null
                                              ? 'Category Products'
                                              : 'Available Products',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${products.length} item${products.length == 1 ? '' : 's'}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.68,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (
                                  context,
                                  index,
                                ) {
                                  final card = ProductCard(
                                    product: products[index],
                                  );

                                  if (index < 4) {
                                    return AppSlideIn(
                                      delay: Duration(milliseconds: index * 40),
                                      duration:
                                          const Duration(milliseconds: 260),
                                      distance: 0.06,
                                      curve: Curves.easeOutCubic,
                                      child: card,
                                    );
                                  }

                                  return card;
                                },
                                childCount: products.length,
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(
                                height: 40,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _InitialCatalogState(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreHint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StoreHint({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 15,
          color: AppColors.textSecondary,
        ),
        const SizedBox(
          width: 6,
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              height: 1.4,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _CatalogError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CatalogError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 340,
          ),
          child: AppScaleIn(
            duration: const Duration(milliseconds: 300),
            beginScale: 0.9,
            curve: Curves.easeOutCubic,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                const Text(
                  'Unable to load products',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(
                  height: 7,
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Try Again',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCatalog extends StatelessWidget {
  final bool categorySelected;

  const _EmptyCatalog({
    required this.categorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: AppScaleIn(
          duration: const Duration(milliseconds: 300),
          beginScale: 0.9,
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_basket_outlined,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(
                height: 14,
              ),
              Text(
                categorySelected
                    ? 'No products in this category'
                    : 'No products available',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              Text(
                categorySelected
                    ? 'Try another category or refresh the catalog.'
                    : 'There are currently no available products for this store.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InitialCatalogState extends StatelessWidget {
  const _InitialCatalogState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: AppScaleIn(
          duration: const Duration(milliseconds: 300),
          beginScale: 0.9,
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(
                    22,
                  ),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'Choose a store',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              const Text(
                'Select a store above to view its available products and prices.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
