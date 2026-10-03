import 'dart:async';
import 'package:flutter/material.dart';

/// A reusable widget that scales and fades its child in.
/// Respects accessibility reduced motion settings.
class AppScaleIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double beginScale;
  final double endScale;
  final bool fadeIn;

  const AppScaleIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 350),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutBack,
    this.beginScale = 0.85,
    this.endScale = 1.0,
    this.fadeIn = true,
  });

  @override
  State<AppScaleIn> createState() => _AppScaleInState();
}

class _AppScaleInState extends State<AppScaleIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
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

    Widget current = ScaleTransition(
      scale: _scaleAnimation,
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
