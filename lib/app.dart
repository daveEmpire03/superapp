import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

import 'features/cart/presentation/bloc/cart_event.dart';
import 'features/cart/presentation/providers/cart_state_provider.dart';
import 'features/catalog/presentation/bloc/product_event.dart';
import 'features/catalog/presentation/bloc/product_state.dart';
import 'features/catalog/presentation/providers/product_state_provider.dart';
import 'features/stores/presentation/bloc/store_event.dart';
import 'features/stores/presentation/bloc/store_state.dart';
import 'features/stores/presentation/providers/store_state_provider.dart';

class BokkuMartApp extends ConsumerStatefulWidget {
  const BokkuMartApp({super.key});

  @override
  ConsumerState<BokkuMartApp> createState() => _BokkuMartAppState();
}

class _BokkuMartAppState extends ConsumerState<BokkuMartApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(cartStateProvider.notifier).add(const LoadCartEvent());
      ref.read(storeStateProvider.notifier).add(const LoadStoresEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<StoreState>(storeStateProvider, (previous, current) {
      if (current is! StoreLoaded) return;

      final storeId = current.selectedStore?.id;
      final previousStoreId =
          previous is StoreLoaded ? previous.selectedStore?.id : null;

      final catalog = ref.read(productStateProvider.notifier);
      if (previous is StoreLoaded &&
          previousStoreId == storeId &&
          ref.read(productStateProvider) is! ProductInitial) {
        return;
      }

      catalog.add(LoadCatalogEvent(storeId: storeId));
    });

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
