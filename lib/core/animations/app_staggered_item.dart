import 'package:flutter/material.dart';
import 'app_slide_in.dart';

/// A reusable widget that staggers the entrance of items in a list or column.
/// Calculates animation delay based on [index].
class AppStaggeredItem extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration itemDuration;
  final Duration baseDelay;
  final Duration staggerInterval;
  final SlideDirection direction;
  final double distance;
  final Curve curve;

  const AppStaggeredItem({
    super.key,
    required this.index,
    required this.child,
    this.itemDuration = const Duration(milliseconds: 300),
    this.baseDelay = Duration.zero,
    this.staggerInterval = const Duration(milliseconds: 60),
    this.direction = SlideDirection.fromBottom,
    this.distance = 0.12,
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    final totalDelay = baseDelay + (staggerInterval * index);

    return AppSlideIn(
      delay: totalDelay,
      duration: itemDuration,
      direction: direction,
      distance: distance,
      curve: curve,
      fadeIn: true,
      child: child,
    );
  }
}
