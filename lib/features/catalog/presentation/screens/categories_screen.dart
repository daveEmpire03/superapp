import 'package:bokku_mart/features/catalog/presentation/providers/product_state_provider.dart';
import 'package:bokku_mart/core/providers/riverpod_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/product_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aisles & Categories',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: RiverpodBuilder<ProductState>(
      provider: productStateProvider,
        builder: (context, state) {
          if (state is! ProductLoaded) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          final categories = state.categories;
          final selectedCategory =
              state.selectedCategory ?? categories.first.id;

          return Row(
            children: [
              // Left Category Rail
              Container(
                width: 105,
                color: AppColors.surfaceElevated,
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = selectedCategory == cat.id;

                    return InkWell(
                      onTap: () {
                        ProviderScope.containerOf(context, listen: false).read(productStateProvider.notifier)
                            .add(FilterByCategoryEvent(cat.id));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          border: Border(
                            left: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 4,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(cat.icon,
                                style: const TextStyle(fontSize: 26)),
                            const SizedBox(height: 6),
                            Text(
                              cat.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Right Product Grid
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Builder(
                    builder: (context) {
                      final items = state.allProducts
                          .where((p) =>
                              p.category.toLowerCase() ==
                              selectedCategory.toLowerCase())
                          .toList();

                      if (items.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.inventory_2_outlined,
                                  size: 48, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              const Text('No products in this category yet.'),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  ProviderScope.containerOf(context, listen: false).read(productStateProvider.notifier).add(
                                      const FilterByCategoryEvent('groceries'));
                                },
                                child: const Text('View Groceries'),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return ProductCard(
                              product: items[index], width: double.infinity);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
