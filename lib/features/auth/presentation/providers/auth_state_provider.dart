import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/repositories/auth_repository.dart';
import '../bloc/auth_state.dart';
import '../../../../core/error/exceptions.dart';

final authStateProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  AuthRepository get authRepository => ref.read(authRepositoryProvider);

  @override
  AuthState build() => const AuthInitial();

  Future<void> checkAuthStatus() async {
    state = const AuthLoading();

    try {
      final user = await authRepository.getCurrentUser();

      if (user == null) {
        state = const Unauthenticated();
        return;
      }

      state = Authenticated(user);
    } catch (error) {
      state = AuthError(_messageFromError(error));
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();

    try {
      final user = await authRepository.signInWithEmailPassword(
        email: email,
        password: password,
      );

      state = Authenticated(user);
    } catch (error) {
      if (error is ServerException &&
          error.code == 'email_verification_required') {
        final resolvedEmail =
            error.getString('email') ?? email.trim().toLowerCase();

        state = EmailVerificationRequired(
          email: resolvedEmail,
          message: error.message,
          emailSent: false,
        );

        return;
      }

      state = AuthError(_messageFromError(error));
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AuthLoading();

    try {
      final result = await authRepository.registerUser(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );

      if (result.requiresEmailVerification) {
        state = EmailVerificationRequired(
          email: result.email,
          message: result.message,
          emailSent: result.emailSent,
        );

        return;
      }

      state = AuthError(result.message);
    } catch (error) {
      state = AuthError(_messageFromError(error));
    }
  }

  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    state = const AuthLoading();

    try {
      final user = await authRepository.verifyEmail(
        email: email,
        code: code,
      );

      state = Authenticated(user);
    } catch (error) {
      state = AuthError(_messageFromError(error));
    }
  }

  Future<void> resendEmailVerification({
    required String email,
  }) async {
    state = const AuthLoading();

    try {
      final message = await authRepository.resendEmailVerification(
        email: email,
      );

      state = EmailVerificationCodeResent(
        email: email,
        message: message,
      );
    } catch (error) {
      state = AuthError(_messageFromError(error));
    }
  }

  Future<void> forgotPassword({
    required String email,
  }) async {
    state = const AuthLoading();

    try {
      final trimmedEmail = email.trim().toLowerCase();

      final message = await authRepository.forgotPassword(
        email: trimmedEmail,
      );

      state = PasswordResetCodeSent(
        email: trimmedEmail,
        message: message,
      );
    } catch (error) {
      state = AuthError(_messageFromError(error));
    }
  }

  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    state = const AuthLoading();

    try {
      final trimmedEmail = email.trim().toLowerCase();

      final resetToken = await authRepository.verifyPasswordResetCode(
        email: trimmedEmail,
        code: code.trim(),
      );

      state = PasswordResetCodeVerified(
        email: trimmedEmail,
        resetToken: resetToken,
      );
    } catch (error) {
      state = AuthError(_messageFromError(error));
    }
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = const AuthLoading();

    try {
      final message = await authRepository.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      state = PasswordResetSuccess(
        message: message,
      );
    } catch (error) {
      state = AuthError(_messageFromError(error));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = const AuthLoading();

    try {
      final message = await authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      state = PasswordChangeSuccess(
        message: message,
      );
    } catch (error) {
      state = AuthError(_messageFromError(error));
    }
  }

  Future<void> signOut() async {
    state = const AuthLoading();

    try {
      await authRepository.signOut();
    } finally {
      state = const Unauthenticated();
    }
  }



  String _messageFromError(
    Object error,
  ) {
    if (error is NetworkException) {
      return error.message;
    }

    if (error is ServerException) {
      return error.message;
    }

    if (error is CacheException) {
      return error.message;
    }

    return 'Something went wrong. Please try again.';
  }
}
