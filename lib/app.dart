import 'package:bokku_mart/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

import 'features/cart/presentation/providers/cart_state_provider.dart';
import 'features/catalog/presentation/bloc/product_state.dart';
import 'features/catalog/presentation/providers/product_state_provider.dart';
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

      // 1) Restore auth session from secure storage BEFORE anything else.
      //    This drives the router's redirect: splash → signin OR splash → home.
      ref.read(authStateProvider.notifier).checkAuthStatus();

      // 2) Cart and stores are customer-facing. Loading them unconditionally
      //    is safe — the backend scopes cart to the current user, and the
      //    stores endpoint is public. Riders will simply carry an empty cart.
      ref.read(cartStateProvider.notifier).loadCart();
      ref.read(storeStateProvider.notifier).loadStores();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<StoreState>(storeStateProvider, (previous, current) {
      if (current is! StoreLoaded) return;

      final storeId = current.selectedStore?.id;
      final previousStoreId = previous is StoreLoaded
          ? previous.selectedStore?.id
          : null;

      final catalog = ref.read(productStateProvider.notifier);
      if (previous is StoreLoaded &&
          previousStoreId == storeId &&
          ref.read(productStateProvider) is! ProductInitial) {
        return;
      }

      catalog.loadCatalog(storeId: storeId);
    });

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
