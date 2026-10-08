import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/riverpod_ui.dart';
import '../providers/auth_state_provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();

  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get _hasValidToken => widget.resetToken.trim().isNotEmpty;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  String? _validatePassword(
    String? value,
  ) {
    if (value == null || value.isEmpty) {
      return 'Enter your new password';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  String? _validateConfirmation(
    String? value,
  ) {
    if (value == null || value.isEmpty) {
      return 'Confirm your new password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!_hasValidToken) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    ProviderScope.containerOf(context, listen: false).read(authStateProvider.notifier).add(
          ResetPasswordSubmittedEvent(
            resetToken: widget.resetToken,
            newPassword: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
          ),
        );
  }

  void _showError(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.accentRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasValidToken) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_clock_outlined,
                    size: 56,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Reset session unavailable',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Request a new password reset code to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.goNamed(
                        RouteNames.forgotPassword,
                      );
                    },
                    child: const Text(
                      'Request New Code',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RiverpodConsumer<AuthState>(
      provider: authStateProvider,
      listener: (
        context,
        state,
      ) {
        if (state is PasswordResetSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                ),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );

          context.goNamed(
            RouteNames.signIn,
          );

          return;
        }

        if (state is AuthError) {
          _showError(
            state.message,
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
                  child: Form(
                    key: _formKey,
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
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            size: 42,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Create new password',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Choose a new password for ${widget.email}.',
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 34),
                        const Text(
                          'New password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 9),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.newPassword,
                          ],
                          validator: _validatePassword,
                          decoration: InputDecoration(
                            hintText: 'Minimum 8 characters',
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.primarySurface.withValues(
                              alpha: 0.45,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Confirm password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 9),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          validator: _validateConfirmation,
                          onFieldSubmitted: (_) {
                            _submit();
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter password again',
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.primarySurface.withValues(
                              alpha: 0.45,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submit,
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
                                    'Update Password',
                                    style: TextStyle(
                                      fontSize: 16,
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
      },
    );
  }
}
