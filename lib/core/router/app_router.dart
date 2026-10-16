import 'package:bokku_mart/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:bokku_mart/riders/screens/rider_earnings_screen.dart';
import 'package:bokku_mart/riders/screens/rider_home_screen.dart';
import 'package:bokku_mart/riders/screens/rider_job_detail_screen.dart';
import 'package:bokku_mart/riders/screens/rider_jobs_screen.dart';
import 'package:bokku_mart/riders/screens/rider_profile_screen.dart';
import 'package:bokku_mart/riders/screens/rider_shell_screen.dart';
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

// Rider

// -----------------------------------------------------------------------------
// Role-aware routing helpers
// -----------------------------------------------------------------------------

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

const Set<String> _publicPaths = {
  '/',
  '/onboarding',
  '/signin',
  '/register',
  '/verify-email',
  '/forgot-password',
  '/verify-password-reset',
  '/reset-password',
};

const Set<String> _sharedPaths = {'/change-password', '/notifications'};

String _homeForRole(UserRole role) {
  switch (role) {
    case UserRole.rider:
      return '/rider/home';
    case UserRole.admin:
    case UserRole.storeManager:
    case UserRole.staff:
    case UserRole.customer:
      return '/home';
  }
}

bool _isAllowed(UserRole role, String path) {
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

      if (authState is Unauthenticated) {
        if (path == '/') return '/signin';
        if (isPublicPath) return null;
        return '/signin';
      }

      if (authState is Authenticated) {
        final role = authState.user.roleEnum;
        final home = _homeForRole(role);

        if (isPublicPath) return home;
        if (!_isAllowed(role, path)) return home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/onboarding',
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ---------------- Auth ----------------
      GoRoute(
        path: '/signin',
        name: RouteNames.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/register',
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
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
        builder: (context, state) => const ForgotPasswordScreen(),
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
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      // ---------------- Catalog ----------------
      GoRoute(
        path: '/search',
        name: RouteNames.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/product-detail/:id',
        name: RouteNames.productDetail,
        builder: (context, state) {
          final product = state.extra as ProductEntity;
          return ProductDetailScreen(product: product);
        },
      ),

      // ---------------- Checkout / Orders ----------------
      GoRoute(
        path: '/checkout',
        name: RouteNames.checkout,
        builder: (context, state) => const CheckoutScreen(),
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
        builder: (context, state) => const OrdersHistoryScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: RouteNames.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),

      // ---------------- Mobility ----------------
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

      // ---------------- Rider detail (outside shell — full screen) ----------------
      GoRoute(
        path: '/rider/jobs/:id',
        name: 'riderJobDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return RiderJobDetailScreen(jobId: id);
        },
      ),

      // ---------------- Customer shell ----------------
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
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                name: RouteNames.categories,
                builder: (context, state) => const CategoriesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/deals',
                name: RouteNames.deals,
                builder: (context, state) => const DealsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                name: RouteNames.cart,
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                name: RouteNames.account,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ---------------- Rider shell ----------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return RiderShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rider/home',
                name: 'riderHome',
                builder: (context, state) => const RiderHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rider/jobs',
                name: 'riderJobs',
                builder: (context, state) => const RiderJobsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rider/earnings',
                name: 'riderEarnings',
                builder: (context, state) => const RiderEarningsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rider/profile',
                name: 'riderProfile',
                builder: (context, state) => const RiderProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
