import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import 'route_names.dart';

// Auth
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

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
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

      // -----------------------------------------------------------------------
      // Authentication
      // -----------------------------------------------------------------------

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

          return VerifyEmailScreen(
            email: email,
            initialEmailSent: emailSent,
          );
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

          return VerifyPasswordResetScreen(
            email: email,
          );
        },
      ),

      GoRoute(
        path: '/reset-password',
        name: RouteNames.resetPassword,
        builder: (context, state) {
          final email = state.uri.queryParameters['email']?.trim() ?? '';

          final resetToken =
              state.extra is String ? state.extra! as String : '';

          return ResetPasswordScreen(
            email: email,
            resetToken: resetToken,
          );
        },
      ),
      GoRoute(
        path: '/change-password',
        name: RouteNames.changePassword,
        builder: (context, state) {
          return const ChangePasswordScreen();
        },
      ),
      // -----------------------------------------------------------------------
      // Catalog
      // -----------------------------------------------------------------------

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

          return ProductDetailScreen(
            product: product,
          );
        },
      ),

      // -----------------------------------------------------------------------
      // Checkout / Orders
      // -----------------------------------------------------------------------

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

          return OrderSuccessScreen(
            order: order,
          );
        },
      ),

      GoRoute(
        path: '/order-tracking/:id',
        name: RouteNames.orderTracking,
        builder: (context, state) {
          final order = state.extra as OrderEntity;

          return OrderTrackingScreen(
            order: order,
          );
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

      // -----------------------------------------------------------------------
      // Persistent Navigation
      // -----------------------------------------------------------------------

      StatefulShellRoute.indexedStack(
        builder: (
          context,
          state,
          navigationShell,
        ) {
          return MainShellScreen(
            navigationShell: navigationShell,
          );
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
}
