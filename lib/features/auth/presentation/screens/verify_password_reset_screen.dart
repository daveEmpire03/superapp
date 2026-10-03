import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerifyPasswordResetScreen extends StatefulWidget {
  final String email;

  const VerifyPasswordResetScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyPasswordResetScreen> createState() =>
      _VerifyPasswordResetScreenState();
}

class _VerifyPasswordResetScreenState extends State<VerifyPasswordResetScreen> {
  final _codeController = TextEditingController();

  Timer? _timer;

  int _secondsRemaining = 60;

  String get _email => widget.email.trim().toLowerCase();

  bool get _canResend => _secondsRemaining <= 0;

  bool get _validCode => _codeController.text.trim().length == 6;

  @override
  void initState() {
    super.initState();

    _codeController.addListener(
      _refresh,
    );

    _startTimer();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _secondsRemaining = 60;
    });

    _timer = Timer.periodic(
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

  void _verify() {
    if (!_validCode) {
      return;
    }

    context.read<AuthBloc>().add(
          VerifyPasswordResetCodeSubmittedEvent(
            email: _email,
            code: _codeController.text.trim(),
          ),
        );
  }

  void _resend() {
    if (!_canResend) {
      return;
    }

    context.read<AuthBloc>().add(
          ForgotPasswordSubmittedEvent(
            email: _email,
          ),
        );
  }

  void _showMessage(
    String message, {
    required bool error,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? AppColors.accentRed : AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController
      ..removeListener(_refresh)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_email.isEmpty) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              context.goNamed(
                RouteNames.forgotPassword,
              );
            },
            child: const Text(
              'Start Password Reset',
            ),
          ),
        ),
      );
    }

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (
        context,
        state,
      ) {
        if (state is PasswordResetCodeVerified) {
          context.goNamed(
            RouteNames.resetPassword,
            queryParameters: {
              'email': state.email,
            },
            extra: state.resetToken,
          );

          return;
        }

        if (state is PasswordResetCodeSent) {
          _codeController.clear();

          _startTimer();

          _showMessage(
            state.message,
            error: false,
          );

          return;
        }

        if (state is AuthError) {
          _showMessage(
            state.message,
            error: true,
          );
        }
      },
      builder: (
        context,
        state,
      ) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 460,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                context.goNamed(
                                  RouteNames.forgotPassword,
                                );
                              },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            28,
                          ),
                        ),
                        child: const Icon(
                          Icons.password_rounded,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Check your email',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Enter the 6-digit password reset code sent to',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _email,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 34),
                      TextField(
                        controller: _codeController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        autofillHints: const [
                          AutofillHints.oneTimeCode,
                        ],
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(
                            6,
                          ),
                        ],
                        style: const TextStyle(
                          fontSize: 28,
                          letterSpacing: 10,
                          fontWeight: FontWeight.w800,
                        ),
                        decoration: InputDecoration(
                          hintText: '000000',
                          filled: true,
                          fillColor: AppColors.primarySurface.withValues(
                            alpha: 0.45,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading || !_validCode ? null : _verify,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Verify Code',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Center(
                        child: TextButton(
                          onPressed: isLoading || !_canResend ? null : _resend,
                          child: Text(
                            _canResend
                                ? 'Resend Code'
                                : 'Resend in ${_secondsRemaining}s',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'Reset codes expire after 10 minutes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
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
