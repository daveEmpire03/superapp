import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/animations/animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void _onSignIn() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<AuthBloc>().add(
          SignInSubmittedEvent(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  String? _validateEmail(
    String? value,
  ) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Enter your email address';
    }

    final emailPattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(
    String? value,
  ) {
    if (value == null || value.isEmpty) {
      return 'Enter your password';
    }

    return null;
  }

  void _goToRegister() {
    context.pushNamed(
      RouteNames.register,
    );
  }

  void _goToVerifyEmail(
    EmailVerificationRequired state,
  ) {
    context.goNamed(
      RouteNames.verifyEmail,
      queryParameters: {
        'email': state.email,
        'sent': state.emailSent.toString(),
      },
    );
  }

  void _showError(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
          backgroundColor: AppColors.accentRed,
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
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (
        context,
        state,
      ) {
        if (state is EmailVerificationRequired) {
          _goToVerifyEmail(
            state,
          );

          return;
        }

        if (state is Authenticated) {
          context.goNamed(
            RouteNames.home,
          );

          return;
        }

        if (state is AuthError) {
          _showError(
            state.message,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            behavior: HitTestBehavior.translucent,
            child: LayoutBuilder(
              builder: (
                context,
                constraints,
              ) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    16,
                    24,
                    24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 40,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 460,
                        ),
                        child: AutofillGroup(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppSlideIn(
                                  direction: SlideDirection.fromTop,
                                  duration: const Duration(milliseconds: 320),
                                  distance: 0.08,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildTopNavigation(),
                                      const SizedBox(height: 30),
                                      const _BrandHeader(),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 42,
                                ),
                                const AppSlideIn(
                                  delay: Duration(milliseconds: 70),
                                  duration: Duration(milliseconds: 300),
                                  direction: SlideDirection.fromBottom,
                                  distance: 0.08,
                                  curve: Curves.easeOutCubic,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome back',
                                        style: TextStyle(
                                          fontSize: 30,
                                          height: 1.1,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textPrimary,
                                          letterSpacing: -0.8,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Sign in to continue shopping for your everyday essentials with Bokku Mart.',
                                        style: TextStyle(
                                          fontSize: 15,
                                          height: 1.55,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 34,
                                ),
                                AppSlideIn(
                                  delay: const Duration(milliseconds: 140),
                                  duration: const Duration(milliseconds: 320),
                                  direction: SlideDirection.fromBottom,
                                  distance: 0.08,
                                  curve: Curves.easeOutCubic,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _FieldLabel(
                                        label: 'Email address',
                                      ),
                                      const SizedBox(
                                        height: 9,
                                      ),
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.email,
                                        ],
                                        autocorrect: false,
                                        validator: _validateEmail,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                        decoration: _inputDecoration(
                                          hintText: 'you@example.com',
                                          prefixIcon: Icons.email_outlined,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 22,
                                      ),
                                      Row(
                                        children: [
                                          const Expanded(
                                            child: _FieldLabel(
                                              label: 'Password',
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              context.pushNamed(
                                                  RouteNames.forgotPassword);
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: const Text(
                                              'Forgot Password?',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 9,
                                      ),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        textInputAction: TextInputAction.done,
                                        autofillHints: const [
                                          AutofillHints.password,
                                        ],
                                        validator: _validatePassword,
                                        onFieldSubmitted: (_) {
                                          _onSignIn();
                                        },
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                        decoration: _inputDecoration(
                                          hintText: 'Enter your password',
                                          prefixIcon:
                                              Icons.lock_outline_rounded,
                                          suffixIcon: IconButton(
                                            tooltip: _obscurePassword
                                                ? 'Show password'
                                                : 'Hide password',
                                            onPressed: () {
                                              setState(
                                                () {
                                                  _obscurePassword =
                                                      !_obscurePassword;
                                                },
                                              );
                                            },
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons
                                                      .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              size: 21,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                AppSlideIn(
                                  delay: const Duration(milliseconds: 200),
                                  duration: const Duration(milliseconds: 300),
                                  direction: SlideDirection.fromBottom,
                                  distance: 0.08,
                                  curve: Curves.easeOutCubic,
                                  child: BlocBuilder<AuthBloc, AuthState>(
                                    builder: (
                                      context,
                                      state,
                                    ) {
                                      final isLoading = state is AuthLoading;

                                      return SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed:
                                              isLoading ? null : _onSignIn,
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            disabledBackgroundColor: AppColors
                                                .primary
                                                .withValues(alpha: 0.55),
                                            disabledForegroundColor:
                                                Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                18,
                                              ),
                                            ),
                                          ),
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            transitionBuilder:
                                                (child, animation) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: ScaleTransition(
                                                  scale: Tween<double>(
                                                    begin: 0.88,
                                                    end: 1.0,
                                                  ).animate(
                                                    CurvedAnimation(
                                                      parent: animation,
                                                      curve:
                                                          Curves.easeOutCubic,
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
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2.4,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : const Row(
                                                    key: ValueKey(
                                                      'sign-in',
                                                    ),
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        'Sign In',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .arrow_forward_rounded,
                                                        size: 20,
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 32,
                                ),
                                AppFadeIn(
                                  delay: const Duration(milliseconds: 260),
                                  duration: const Duration(milliseconds: 320),
                                  curve: Curves.easeOutCubic,
                                  child: Column(
                                    children: [
                                      const _OrDivider(),
                                      const SizedBox(
                                        height: 28,
                                      ),
                                      _CreateAccountSection(
                                        onPressed: _goToRegister,
                                      ),
                                      const SizedBox(
                                        height: 26,
                                      ),
                                      const _SecurityMessage(),
                                    ],
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavigation() {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          if (context.canPop())
            Material(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () {
                  context.pop();
                },
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
            )
          else
            const SizedBox(
              width: 44,
              height: 44,
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withValues(
          alpha: 0.75,
        ),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: AppColors.primarySurface.withValues(
        alpha: 0.45,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      prefixIcon: Icon(
        prefixIcon,
        size: 21,
        color: AppColors.textSecondary,
      ),
      suffixIcon: suffixIcon,
      prefixIconConstraints: const BoxConstraints(
        minWidth: 52,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(
          color: AppColors.border.withValues(
            alpha: 0.9,
          ),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(
          color: AppColors.border.withValues(
            alpha: 0.9,
          ),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: AppColors.accentRed,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: AppColors.accentRed,
          width: 1.6,
        ),
      ),
      errorStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.accentRed,
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: 0.18,
                ),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.shopping_bag_rounded,
            size: 27,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 13),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bokku Mart',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Smart grocery shopping',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            height: 1,
            color: AppColors.border.withValues(
              alpha: 0.8,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 14,
          ),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            height: 1,
            color: AppColors.border.withValues(
              alpha: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}

class _CreateAccountSection extends StatelessWidget {
  final VoidCallback onPressed;

  const _CreateAccountSection({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primarySurface.withValues(
          alpha: 0.55,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.75,
          ),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'New to Bokku Mart?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Create an account and start shopping.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(
                  color: AppColors.primary,
                  width: 1.3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                ),
              ),
              child: const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityMessage extends StatelessWidget {
  const _SecurityMessage();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_rounded,
          size: 14,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            'Your account information is securely protected',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
