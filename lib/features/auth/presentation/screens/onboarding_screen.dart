import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  static const List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      icon: Icons.local_offer_rounded,
      title: 'Better Prices.\nEveryday Essentials.',
      description:
          'Shop groceries, household essentials, food items, and more at Bokku Mart prices designed to help you spend less.',
      badge: 'SAVE MORE',
    ),
    _OnboardingPageData(
      icon: Icons.delivery_dining_rounded,
      title: 'Groceries Delivered\nTo Your Doorstep',
      description:
          'Choose a Bokku Mart store, add what you need to your basket, and have your order delivered conveniently.',
      badge: 'FAST DELIVERY',
    ),
    _OnboardingPageData(
      icon: Icons.storefront_rounded,
      title: 'Shop From The Store\nThat Works For You',
      description:
          'Browse available Bokku Mart stores, compare what is available, and choose the most convenient store for your order.',
      badge: 'YOUR STORE',
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_isLastPage) {
      context.goNamed(RouteNames.home);
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _skipOnboarding() {
    context.goNamed(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppSlideIn(
              direction: SlideDirection.fromTop,
              duration: const Duration(milliseconds: 350),
              distance: 0.1,
              child: _OnboardingHeader(
                currentPage: _currentPage,
                pageCount: _pages.length,
                onSkip: _skipOnboarding,
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _OnboardingPage(
                    key: ValueKey<int>(index),
                    data: _pages[index],
                    pageIndex: index,
                  );
                },
              ),
            ),
            AppSlideIn(
              direction: SlideDirection.fromBottom,
              duration: const Duration(milliseconds: 350),
              distance: 0.08,
              child: _BottomSection(
                currentPage: _currentPage,
                pageCount: _pages.length,
                isLastPage: _isLastPage,
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({
    required this.currentPage,
    required this.pageCount,
    required this.onSkip,
  });

  final int currentPage;
  final int pageCount;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        16,
        16,
        8,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bokku Mart',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'Smart grocery shopping',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          AnimatedOpacity(
            opacity: currentPage < pageCount - 1 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: IgnorePointer(
              ignoring: currentPage >= pageCount - 1,
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    super.key,
    required this.data,
    required this.pageIndex,
  });

  final _OnboardingPageData data;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    final illustrationSize = screenHeight < 700 ? 220.0 : 270.0;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: Column(
        children: [
          SizedBox(
            height: screenHeight < 700 ? 24 : 44,
          ),
          _IllustrationCard(
            icon: data.icon,
            badge: data.badge,
            size: illustrationSize,
            pageIndex: pageIndex,
          ),
          SizedBox(
            height: screenHeight < 700 ? 28 : 42,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: AppSlideIn(
              delay: const Duration(milliseconds: 90),
              duration: const Duration(milliseconds: 320),
              direction: SlideDirection.fromBottom,
              distance: 0.1,
              curve: Curves.easeOutCubic,
              child: Column(
                children: [
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenHeight < 700 ? 27 : 31,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationCard extends StatelessWidget {
  const _IllustrationCard({
    required this.icon,
    required this.badge,
    required this.size,
    required this.pageIndex,
  });

  final IconData icon;
  final String badge;
  final double size;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 22,
            right: 20,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.7,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 20,
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary.withValues(
                    alpha: 0.10,
                  ),
                  width: 10,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: AppScaleIn(
              duration: const Duration(milliseconds: 320),
              beginScale: 0.88,
              curve: Curves.easeOutCubic,
              child: Container(
                width: size * 0.48,
                height: size * 0.48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(
                    size * 0.16,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: 0.22,
                      ),
                      blurRadius: 32,
                      offset: const Offset(
                        0,
                        16,
                      ),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: size * 0.24,
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 18,
            child: AppScaleIn(
              delay: const Duration(milliseconds: 80),
              duration: const Duration(milliseconds: 260),
              beginScale: 0.82,
              curve: Curves.easeOutBack,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.06,
                      ),
                      blurRadius: 12,
                      offset: const Offset(
                        0,
                        4,
                      ),
                    ),
                  ],
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 18,
            bottom: 18,
            child: AppSlideIn(
              delay: const Duration(milliseconds: 110),
              duration: const Duration(milliseconds: 280),
              direction: SlideDirection.fromBottom,
              distance: 0.12,
              curve: Curves.easeOutCubic,
              child: _MiniFeatureIcon(
                icon: _featureIconForPage(pageIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _featureIconForPage(int index) {
    switch (index) {
      case 0:
        return Icons.savings_rounded;
      case 1:
        return Icons.schedule_rounded;
      case 2:
        return Icons.location_on_rounded;
      default:
        return Icons.shopping_cart_rounded;
    }
  }
}

class _MiniFeatureIcon extends StatelessWidget {
  const _MiniFeatureIcon({
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.07,
            ),
            blurRadius: 16,
            offset: const Offset(
              0,
              7,
            ),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: AppColors.primary,
        size: 26,
      ),
    );
  }
}

class _BottomSection extends StatelessWidget {
  const _BottomSection({
    required this.currentPage,
    required this.pageCount,
    required this.isLastPage,
    required this.onPressed,
  });

  final int currentPage;
  final int pageCount;
  final bool isLastPage;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24,
      ),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pageCount,
              (index) {
                final isSelected = currentPage == index;

                return AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 250,
                  ),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  width: isSelected ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 220,
                ),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.15),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                child: Row(
                  key: ValueKey<bool>(isLastPage),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLastPage ? 'Start Shopping' : 'Continue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      isLastPage
                          ? Icons.shopping_bag_rounded
                          : Icons.arrow_forward_rounded,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.badge,
  });

  final IconData icon;
  final String title;
  final String description;
  final String badge;
}
