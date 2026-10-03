import 'package:bokku_mart/features/cart/presentation/bloc/cart_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

// Auth
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Catalog
import 'features/catalog/presentation/bloc/product_bloc.dart';
import 'features/catalog/presentation/bloc/product_event.dart';
import 'features/catalog/presentation/bloc/product_state.dart';

// Cart
import 'features/cart/presentation/bloc/cart_bloc.dart';
// Checkout
import 'features/checkout/presentation/bloc/checkout_bloc.dart';
// Stores
import 'features/stores/presentation/bloc/store_bloc.dart';
import 'features/stores/presentation/bloc/store_event.dart';
import 'features/stores/presentation/bloc/store_state.dart';

class BokkuMartApp extends StatelessWidget {
  const BokkuMartApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
        ),
        BlocProvider<ProductBloc>(
          create: (_) => sl<ProductBloc>(),
        ),
        BlocProvider<CartBloc>(
          create: (_) => sl<CartBloc>()
            ..add(
              const LoadCartEvent(),
            ),
        ),
        BlocProvider<CheckoutBloc>(
          create: (_) => sl<CheckoutBloc>(),
        ),
        BlocProvider<StoreBloc>(
          create: (_) => sl<StoreBloc>()
            ..add(
              const LoadStoresEvent(),
            ),
        ),
      ],
      child: BlocListener<StoreBloc, StoreState>(
        listenWhen: (previous, current) {
          return previous is StoreLoading && current is StoreLoaded;
        },
        listener: (context, state) {
          if (state is! StoreLoaded) {
            return;
          }

          final storeId = state.selectedStore?.id;

          final productBloc = context.read<ProductBloc>();

          if (productBloc.selectedStoreId == storeId &&
              productBloc.state is! ProductInitial) {
            return;
          }

          productBloc.add(
            LoadCatalogEvent(
              storeId: storeId,
            ),
          );
        },
        child: MaterialApp.router(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
