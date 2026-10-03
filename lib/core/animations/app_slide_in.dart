import 'dart:async';
import 'package:flutter/material.dart';

enum SlideDirection {
  fromBottom,
  fromTop,
  fromLeft,
  fromRight,
}

/// A reusable widget that slides and fades its child in.
/// Respects accessibility reduced motion settings.
class AppSlideIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Offset? beginOffset;
  final SlideDirection direction;
  final double distance;
  final bool fadeIn;

  const AppSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 350),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.beginOffset,
    this.direction = SlideDirection.fromBottom,
    this.distance = 0.15,
    this.fadeIn = true,
  });

  @override
  State<AppSlideIn> createState() => _AppSlideInState();
}

class _AppSlideInState extends State<AppSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final startOffset = widget.beginOffset ??
        _calculateOffset(widget.direction, widget.distance);

    _slideAnimation = Tween<Offset>(
      begin: startOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  Offset _calculateOffset(SlideDirection direction, double distance) {
    switch (direction) {
      case SlideDirection.fromBottom:
        return Offset(0, distance);
      case SlideDirection.fromTop:
        return Offset(0, -distance);
      case SlideDirection.fromLeft:
        return Offset(-distance, 0);
      case SlideDirection.fromRight:
        return Offset(distance, 0);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return widget.child;
    }

    Widget current = SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );

    if (widget.fadeIn) {
      current = FadeTransition(
        opacity: _fadeAnimation,
        child: current,
      );
    }

    return current;
  }
}
