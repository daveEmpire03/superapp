import 'package:bokku_mart/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

// Auth
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/auth/presentation/screens/verify_password_reset_screen.dart';

// Home
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/main_shell_screen.dart';

// Catalog
import '../../features/catalog/domain/entities/product_entity.dart';
import '../../features/catalog/presentation/screens/categories_screen.dart';
import '../../features/catalog/presentation/screens/product_detail_screen.dart';
import '../../features/catalog/presentation/screens/search_screen.dart';

// Cart
import '../../features/cart/presentation/screens/cart_screen.dart';

// Checkout / Orders
import '../../features/checkout/domain/entities/order_entity.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/checkout/presentation/screens/order_success_screen.dart';
import '../../features/checkout/presentation/screens/order_tracking_screen.dart';
import '../../features/checkout/presentation/screens/orders_history_screen.dart';

// Profile
import '../../features/profile/presentation/screens/deals_screen.dart';
import '../../features/profile/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/mobility/presentation/screens/mobility_screen.dart';
import '../../features/mobility/presentation/screens/location_picker_screen.dart';
import '../../features/mobility/presentation/screens/mobility_tracking_screen.dart';

// -----------------------------------------------------------------------------
// Role-aware routing helpers
// -----------------------------------------------------------------------------

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Paths that anyone (authenticated or not) can land on.
const Set<String> _publicPaths = {
  '/', // splash
  '/onboarding',
  '/signin',
  '/register',
  '/verify-email',
  '/forgot-password',
  '/verify-password-reset',
  '/reset-password',
};

/// Paths that are reachable by every authenticated role, regardless of role.
const Set<String> _sharedPaths = {'/change-password', '/notifications'};

/// The landing route for a role after login / on cold start.
String _homeForRole(UserRole role) {
  switch (role) {
    case UserRole.rider:
      return '/rider/home';
    case UserRole.admin:
    case UserRole.storeManager:
    case UserRole.staff:
    case UserRole.customer:
      // Staff/admin trees are not built yet — fall back to customer home.
      return '/home';
  }
}

/// Is this role allowed to visit this path?
///
/// - Rider-only tree:  anything starting with `/rider`
/// - Shared paths:     allowed for every role
/// - Everything else:  allowed for every role EXCEPT riders
bool _isAllowed(UserRole role, String path) {
  // shared wins first
  for (final shared in _sharedPaths) {
    if (path == shared || path.startsWith('$shared/')) return true;
  }

  if (path.startsWith('/rider')) {
    return role == UserRole.rider;
  }

  return role != UserRole.rider;
}

// -----------------------------------------------------------------------------
// Riverpod → GoRouter refresh bridge
// -----------------------------------------------------------------------------

class _RouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}

// -----------------------------------------------------------------------------
// The router
// -----------------------------------------------------------------------------

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();

  // Whenever auth state changes (login, logout, role change),
  // tell GoRouter to re-run `redirect`.
  ref.listen<AuthState>(authStateProvider, (_, __) => refresh.notify());

  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final path = state.matchedLocation;
      final isPublicPath = _publicPaths.contains(path);

      // --- Unauthenticated -----------------------------------------------
      if (authState is Unauthenticated) {
        // Splash is done checking → push to signin.
        if (path == '/') return '/signin';

        // Other public pages (register, verify-email, forgot-password, etc.)
        // are reachable without auth.
        if (isPublicPath) return null;

        // Any protected path → signin.
        return '/signin';
      }

      // --- Authenticated -------------------------------------------------
      if (authState is Authenticated) {
        final user = authState.user;
        final role = user.roleEnum;
        final home = _homeForRole(role);

        // Authenticated user landing on a public page → send to their home.
        if (isPublicPath) return home;

        // Cross-role access → send back to their home.
        if (!_isAllowed(role, path)) return home;
      }

      // AuthInitial / AuthLoading / AuthError / PasswordChangeSuccess etc.:
      // don't interfere — let the current screen handle it.
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.splash,
        builder: (context, state) {
          return const SplashScreen();
        },
      ),

      GoRoute(
        path: '/onboarding',
        name: RouteNames.onboarding,
        builder: (context, state) {
          return const OnboardingScreen();
        },
      ),

      // ---------------------------------------------------------------------
      // Authentication
      // ---------------------------------------------------------------------
      GoRoute(
        path: '/signin',
        name: RouteNames.signIn,
        builder: (context, state) {
          return const SignInScreen();
        },
      ),

      GoRoute(
        path: '/register',
        name: RouteNames.register,
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),

      GoRoute(
        path: '/verify-email',
        name: RouteNames.verifyEmail,
        builder: (context, state) {
          final email = state.uri.queryParameters['email']?.trim() ?? '';
          final emailSent = state.uri.queryParameters['sent'] != 'false';

          return VerifyEmailScreen(email: email, initialEmailSent: emailSent);
        },
      ),

      GoRoute(
        path: '/forgot-password',
        name: RouteNames.forgotPassword,
        builder: (context, state) {
          return const ForgotPasswordScreen();
        },
      ),

      GoRoute(
        path: '/verify-password-reset',
        name: RouteNames.verifyPasswordReset,
        builder: (context, state) {
          final email = state.uri.queryParameters['email']?.trim() ?? '';

          return VerifyPasswordResetScreen(email: email);
        },
      ),

      GoRoute(
        path: '/reset-password',
        name: RouteNames.resetPassword,
        builder: (context, state) {
          final email = state.uri.queryParameters['email']?.trim() ?? '';
          final resetToken = state.extra is String
              ? state.extra! as String
              : '';

          return ResetPasswordScreen(email: email, resetToken: resetToken);
        },
      ),

      GoRoute(
        path: '/change-password',
        name: RouteNames.changePassword,
        builder: (context, state) {
          return const ChangePasswordScreen();
        },
      ),

      // ---------------------------------------------------------------------
      // Catalog
      // ---------------------------------------------------------------------
      GoRoute(
        path: '/search',
        name: RouteNames.search,
        builder: (context, state) {
          return const SearchScreen();
        },
      ),

      GoRoute(
        path: '/product-detail/:id',
        name: RouteNames.productDetail,
        builder: (context, state) {
          final product = state.extra as ProductEntity;

          return ProductDetailScreen(product: product);
        },
      ),

      // ---------------------------------------------------------------------
      // Checkout / Orders
      // ---------------------------------------------------------------------
      GoRoute(
        path: '/checkout',
        name: RouteNames.checkout,
        builder: (context, state) {
          return const CheckoutScreen();
        },
      ),

      GoRoute(
        path: '/order-success',
        name: RouteNames.orderSuccess,
        builder: (context, state) {
          final order = state.extra as OrderEntity;

          return OrderSuccessScreen(order: order);
        },
      ),

      GoRoute(
        path: '/order-tracking/:id',
        name: RouteNames.orderTracking,
        builder: (context, state) {
          final order = state.extra as OrderEntity;

          return OrderTrackingScreen(order: order);
        },
      ),

      GoRoute(
        path: '/orders',
        name: RouteNames.orders,
        builder: (context, state) {
          return const OrdersHistoryScreen();
        },
      ),

      GoRoute(
        path: '/notifications',
        name: RouteNames.notifications,
        builder: (context, state) {
          return const NotificationsScreen();
        },
      ),

      GoRoute(
        path: '/mobility/tracking',
        name: 'mobilityTracking',
        builder: (context, state) {
          final args = Map<String, dynamic>.from(state.extra as Map);
          return MobilityTrackingScreen(
            serviceType: args['serviceType']?.toString() ?? 'RIDE',
            initialJob: Map<String, dynamic>.from(args['job'] as Map),
          );
        },
      ),

      GoRoute(
        path: '/location-picker',
        name: 'locationPicker',
        builder: (context, state) {
          final args = state.extra is Map
              ? Map<String, dynamic>.from(state.extra as Map)
              : <String, dynamic>{};
          return LocationPickerScreen(
            label: args['label']?.toString() ?? 'Location',
            initialLatitude: (args['latitude'] as num?)?.toDouble(),
            initialLongitude: (args['longitude'] as num?)?.toDouble(),
          );
        },
      ),

      GoRoute(
        path: '/mobility',
        name: 'mobility',
        builder: (context, state) => const MobilityScreen(),
      ),

      // ---------------------------------------------------------------------
      // Rider (placeholder tree — real screens come later)
      // ---------------------------------------------------------------------
      GoRoute(
        path: '/rider/home',
        name: 'riderHome',
        builder: (context, state) =>
            const _RiderPlaceholderScreen(title: 'Rider Home'),
      ),
      GoRoute(
        path: '/rider/jobs',
        name: 'riderJobs',
        builder: (context, state) =>
            const _RiderPlaceholderScreen(title: 'Rider Jobs'),
      ),
      GoRoute(
        path: '/rider/earnings',
        name: 'riderEarnings',
        builder: (context, state) =>
            const _RiderPlaceholderScreen(title: 'Rider Earnings'),
      ),
      GoRoute(
        path: '/rider/profile',
        name: 'riderProfile',
        builder: (context, state) =>
            const _RiderPlaceholderScreen(title: 'Rider Profile'),
      ),

      // ---------------------------------------------------------------------
      // Persistent Navigation (customer shell)
      // ---------------------------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: RouteNames.home,
                builder: (context, state) {
                  return const HomeScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                name: RouteNames.categories,
                builder: (context, state) {
                  return const CategoriesScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/deals',
                name: RouteNames.deals,
                builder: (context, state) {
                  return const DealsScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                name: RouteNames.cart,
                builder: (context, state) {
                  return const CartScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                name: RouteNames.account,
                builder: (context, state) {
                  return const ProfileScreen();
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// -----------------------------------------------------------------------------
// Temporary rider placeholder — will be replaced by real screens in Step 6.
// -----------------------------------------------------------------------------

class _RiderPlaceholderScreen extends StatelessWidget {
  final String title;

  const _RiderPlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title — coming soon',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
