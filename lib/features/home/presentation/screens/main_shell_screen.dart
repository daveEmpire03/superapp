import 'package:bokku_mart/features/cart/presentation/providers/cart_state_provider.dart';
import 'package:bokku_mart/core/providers/riverpod_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../cart/presentation/bloc/cart_state.dart';

class MainShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(
    int index,
  ) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: _BottomNavigation(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavigation({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.06,
            ),
            blurRadius: 22,
            offset: const Offset(
              0,
              -5,
            ),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
          items: [
            BottomNavigationBarItem(
              icon: _NavigationIcon(
                icon: Icons.storefront_outlined,
                selectedIcon: Icons.storefront_rounded,
                selected: currentIndex == 0,
              ),
              label: AppStrings.navHome,
            ),
            BottomNavigationBarItem(
              icon: _NavigationIcon(
                icon: Icons.grid_view_outlined,
                selectedIcon: Icons.grid_view_rounded,
                selected: currentIndex == 1,
              ),
              label: AppStrings.navCategories,
            ),
            BottomNavigationBarItem(
              icon: _NavigationIcon(
                icon: Icons.local_offer_outlined,
                selectedIcon: Icons.local_offer_rounded,
                selected: currentIndex == 2,
              ),
              label: AppStrings.navDeals,
            ),
            BottomNavigationBarItem(
              icon: RiverpodBuilder<CartState>(
      provider: cartStateProvider,
                buildWhen: (
                  previous,
                  current,
                ) {
                  if (previous is CartLoaded && current is CartLoaded) {
                    return previous.totalItemCount != current.totalItemCount;
                  }

                  return previous.runtimeType != current.runtimeType ||
                      current is CartLoaded;
                },
                builder: (
                  context,
                  state,
                ) {
                  final count = state is CartLoaded ? state.totalItemCount : 0;

                  return _CartNavigationIcon(
                    selected: currentIndex == 3,
                    count: count,
                  );
                },
              ),
              label: AppStrings.navCart,
            ),
            BottomNavigationBarItem(
              icon: _NavigationIcon(
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                selected: currentIndex == 4,
              ),
              label: AppStrings.navAccount,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationIcon extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;

  const _NavigationIcon({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(
        horizontal: selected ? 14 : 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: selected ? AppColors.primarySurface : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        selected ? selectedIcon : icon,
        size: 23,
        color: selected ? AppColors.primary : AppColors.textMuted,
      ),
    );
  }
}

class _CartNavigationIcon extends StatelessWidget {
  final bool selected;
  final int count;

  const _CartNavigationIcon({
    required this.selected,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      backgroundColor: AppColors.primary,
      label: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 14 : 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          selected ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined,
          size: 23,
          color: selected ? AppColors.primary : AppColors.textMuted,
        ),
      ),
    );
  }
}
