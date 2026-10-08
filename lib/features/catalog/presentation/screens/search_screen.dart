import 'package:bokku_mart/features/catalog/presentation/providers/product_state_provider.dart';
import 'package:bokku_mart/core/providers/riverpod_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  final List<String> _popularKeywords = [
    'Mama Gold Rice',
    'Golden Penny Spaghetti',
    'Devon Kings Oil',
    'Peak Milk',
    'Tatashey',
    'Indomie',
    'Titus Sardine',
    'Detergent',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ProviderScope.containerOf(context, listen: false).read(productStateProvider.notifier).add(SearchProductsEvent(query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Search food, drinks, toiletries...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        context
                            .read<ProductBloc>()
                            .add(const ClearSearchEvent());
                        setState(() {});
                      },
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
      ),
      body: RiverpodBuilder<ProductState>(
      provider: productStateProvider,
        builder: (context, state) {
          if (state is! ProductLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.isSearching) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (_searchController.text.trim().isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Popular Supermarket Searches 🔥',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _popularKeywords.map((keyword) {
                      return ActionChip(
                        label: Text(keyword),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.border),
                        labelStyle: const TextStyle(
                            fontSize: 12, color: AppColors.textPrimary),
                        onPressed: () {
                          _searchController.text = keyword;
                          _onSearch(keyword);
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }

          if (state.searchResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off_outlined,
                      size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    'No results for "${_searchController.text}"',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check your spelling or browse our aisles for similar products.',
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: state.searchResults.length,
            itemBuilder: (context, index) {
              return ProductCard(product: state.searchResults[index]);
            },
          );
        },
      ),
    );
  }
}
