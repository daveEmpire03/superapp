import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  final bool initialEmailSent;

  const VerifyEmailScreen({
    super.key,
    required this.email,
    this.initialEmailSent = true,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController _codeController = TextEditingController();

  final FocusNode _codeFocusNode = FocusNode();

  Timer? _resendTimer;

  int _secondsRemaining = 0;

  bool get _canResend => _secondsRemaining <= 0;

  bool get _hasValidCode => _codeController.text.trim().length == 6;

  String get _email => widget.email.trim().toLowerCase();

  @override
  void initState() {
    super.initState();

    _codeController.addListener(
      _onCodeChanged,
    );

    if (widget.initialEmailSent) {
      _startResendCountdown();
    }

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted && _email.isNotEmpty) {
          _codeFocusNode.requestFocus();
        }
      },
    );
  }

  void _onCodeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startResendCountdown({
    int seconds = 60,
  }) {
    _resendTimer?.cancel();

    setState(() {
      _secondsRemaining = seconds;
    });

    _resendTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_secondsRemaining <= 1) {
          timer.cancel();

          setState(() {
            _secondsRemaining = 0;
          });

          return;
        }

        setState(() {
          _secondsRemaining--;
        });
      },
    );
  }

  void _verifyEmail() {
    FocusScope.of(context).unfocus();

    final code = _codeController.text.trim();

    if (code.length != 6) {
      _showMessage(
        'Enter the 6-digit verification code.',
        isError: true,
      );

      return;
    }

    context.read<AuthBloc>().add(
          VerifyEmailSubmittedEvent(
            email: _email,
            code: code,
          ),
        );
  }

  void _resendCode() {
    if (!_canResend) {
      return;
    }

    FocusScope.of(context).unfocus();

    context.read<AuthBloc>().add(
          ResendEmailVerificationEvent(
            email: _email,
          ),
        );
  }

  void _showMessage(
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
          backgroundColor: isError ? AppColors.accentRed : AppColors.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              14,
            ),
          ),
        ),
      );
  }

  @override
  void dispose() {
    _resendTimer?.cancel();

    _codeController
      ..removeListener(
        _onCodeChanged,
      )
      ..dispose();

    _codeFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_email.isEmpty) {
      return const _MissingEmailScreen();
    }

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.goNamed(
            RouteNames.home,
          );

          return;
        }

        if (state is EmailVerificationCodeResent) {
          _codeController.clear();

          _startResendCountdown();

          _showMessage(
            state.message,
            isError: false,
          );

          _codeFocusNode.requestFocus();

          return;
        }

        if (state is AuthError) {
          _showMessage(
            state.message,
            isError: true,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  24,
                  18,
                  24,
                  32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 460,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSlideIn(
                          direction: SlideDirection.fromTop,
                          duration: const Duration(milliseconds: 320),
                          distance: 0.08,
                          child: _BackButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context.goNamed(
                                      RouteNames.signIn,
                                    );
                                  },
                          ),
                        ),
                        const SizedBox(height: 36),
                        const AppScaleIn(
                          delay: Duration(milliseconds: 50),
                          duration: Duration(milliseconds: 340),
                          beginScale: 0.85,
                          curve: Curves.easeOutBack,
                          child: _VerificationIcon(),
                        ),
                        const SizedBox(height: 32),
                        AppSlideIn(
                          delay: const Duration(milliseconds: 110),
                          duration: const Duration(milliseconds: 320),
                          direction: SlideDirection.fromBottom,
                          distance: 0.08,
                          curve: Curves.easeOutCubic,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Verify your email',
                                style: TextStyle(
                                  fontSize: 30,
                                  height: 1.1,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'We sent a 6-digit verification code to',
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _email,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Enter the code below to activate your Bokku Mart account.',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),
                        AppSlideIn(
                          delay: const Duration(milliseconds: 160),
                          duration: const Duration(milliseconds: 320),
                          direction: SlideDirection.fromBottom,
                          distance: 0.08,
                          curve: Curves.easeOutCubic,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Verification code',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _codeController,
                                focusNode: _codeFocusNode,
                                enabled: !isLoading,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [
                                  AutofillHints.oneTimeCode,
                                ],
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(
                                    6,
                                  ),
                                ],
                                onSubmitted: (_) {
                                  if (!isLoading && _hasValidCode) {
                                    _verifyEmail();
                                  }
                                },
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 10,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: '000000',
                                  hintStyle: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 10,
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor:
                                      AppColors.primarySurface.withValues(
                                    alpha: 0.45,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 20,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      18,
                                    ),
                                    borderSide: BorderSide(
                                      color: AppColors.border.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      18,
                                    ),
                                    borderSide: BorderSide(
                                      color: AppColors.border.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      18,
                                    ),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.7,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        AppSlideIn(
                          delay: const Duration(milliseconds: 220),
                          duration: const Duration(milliseconds: 300),
                          direction: SlideDirection.fromBottom,
                          distance: 0.08,
                          curve: Curves.easeOutCubic,
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: isLoading || !_hasValidCode
                                      ? null
                                      : _verifyEmail,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        AppColors.primary.withValues(
                                      alpha: 0.45,
                                    ),
                                    disabledForegroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        18,
                                      ),
                                    ),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(
                                      milliseconds: 200,
                                    ),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                          scale: Tween<double>(
                                            begin: 0.88,
                                            end: 1.0,
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
                                    child: isLoading
                                        ? const SizedBox(
                                            key: ValueKey(
                                              'loading',
                                            ),
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.4,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Row(
                                            key: ValueKey(
                                              'verify',
                                            ),
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Verify Email',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Icon(
                                                Icons
                                                    .check_circle_outline_rounded,
                                                size: 21,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              Center(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Didn\'t receive the code?',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    TextButton(
                                      onPressed: isLoading || !_canResend
                                          ? null
                                          : _resendCode,
                                      child: Text(
                                        _canResend
                                            ? 'Resend verification code'
                                            : 'Resend in ${_secondsRemaining}s',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const AppFadeIn(
                          delay: Duration(milliseconds: 280),
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          child: _SecurityNotice(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VerificationIcon extends StatelessWidget {
  const _VerificationIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(
          30,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(
            25,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(
                alpha: 0.20,
              ),
              blurRadius: 24,
              offset: const Offset(
                0,
                10,
              ),
            ),
          ],
        ),
        child: const Icon(
          Icons.mark_email_read_outlined,
          size: 42,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SecurityNotice extends StatelessWidget {
  const _SecurityNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface.withValues(
          alpha: 0.50,
        ),
        borderRadius: BorderRadius.circular(
          18,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'For your security, verification codes expire after 10 minutes.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _BackButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primarySurface,
      borderRadius: BorderRadius.circular(
        14,
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(
          14,
        ),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_back_rounded,
            size: 21,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _MissingEmailScreen extends StatelessWidget {
  const _MissingEmailScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: AppScaleIn(
                duration: const Duration(milliseconds: 350),
                beginScale: 0.9,
                curve: Curves.easeOutCubic,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(
                          24,
                        ),
                      ),
                      child: const Icon(
                        Icons.email_outlined,
                        size: 34,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Email address unavailable',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Return to sign in and continue from your account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          context.goNamed(
                            RouteNames.signIn,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              17,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Go to Sign In',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
