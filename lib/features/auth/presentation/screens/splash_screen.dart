import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/riverpod_ui.dart';
import '../providers/auth_state_provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    ProviderScope.containerOf(context, listen: false).read(authStateProvider.notifier).add(
          const CheckAuthStatusEvent(),
        );
  }

  Future<void> _navigate(
    String routeName,
  ) async {
    if (_hasNavigated) {
      return;
    }

    _hasNavigated = true;

    await Future<void>.delayed(
      const Duration(milliseconds: 650),
    );

    if (!mounted) {
      return;
    }

    context.goNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return RiverpodListener<AuthState>(
      provider: authStateProvider,
      listener: (context, state) {
        if (state is Authenticated) {
          _navigate(RouteNames.home);
          return;
        }

        if (state is Unauthenticated) {
          _navigate(RouteNames.signIn);
          return;
        }

        if (state is AuthError) {
          _navigate(RouteNames.signIn);
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDark,
                AppColors.primary,
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                const AppFadeIn(
                  duration: Duration(milliseconds: 500),
                  child: _BackgroundDecoration(),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppScaleIn(
                          duration: Duration(milliseconds: 380),
                          beginScale: 0.85,
                          endScale: 1.0,
                          curve: Curves.easeOutBack,
                          child: _LogoContainer(),
                        ),
                        const SizedBox(height: 28),
                        AppSlideIn(
                          delay: const Duration(milliseconds: 140),
                          duration: const Duration(milliseconds: 320),
                          direction: SlideDirection.fromBottom,
                          distance: 0.12,
                          curve: Curves.easeOutCubic,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                AppStrings.appName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 36,
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Everything you need, closer to you.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(
                                    alpha: 0.82,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 32,
                  child: AppFadeIn(
                    delay: const Duration(milliseconds: 280),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withValues(
                                alpha: 0.95,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Shopping made simple',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(
                              alpha: 0.65,
                            ),
                            letterSpacing: 0.3,
                          ),
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
    );
  }
}

class _LogoContainer extends StatelessWidget {
  const _LogoContainer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.14,
        ),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.18,
          ),
          width: 1.2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(29),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.16,
              ),
              blurRadius: 28,
              offset: const Offset(
                0,
                12,
              ),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.shopping_bag_rounded,
            size: 54,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: 0.05,
                ),
              ),
            ),
          ),
          Positioned(
            top: 90,
            right: 35,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: 0.08,
                  ),
                  width: 1.5,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -110,
            left: -95,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: 0.045,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
