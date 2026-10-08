import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/repositories/auth_repository.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/error/exceptions.dart';

typedef Emitter<T> = void Function(T value);

final authStateProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  AuthRepository get authRepository => ref.read(authRepositoryProvider);

  @override
  AuthState build() => const AuthInitial();

  void _emit(AuthState value) { state = value; }

  Future<void> add(AuthEvent event) async {
    if (event is CheckAuthStatusEvent) {
      await _onCheckAuthStatus(event, _emit);
    }     else if (event is SignInSubmittedEvent) {
      await _onSignInSubmitted(event, _emit);
    }     else if (event is RegisterSubmittedEvent) {
      await _onRegisterSubmitted(event, _emit);
    }     else if (event is VerifyEmailSubmittedEvent) {
      await _onVerifyEmailSubmitted(event, _emit);
    }     else if (event is ResendEmailVerificationEvent) {
      await _onResendEmailVerification(event, _emit);
    }     else if (event is ForgotPasswordSubmittedEvent) {
      await _onForgotPasswordSubmitted(event, _emit);
    }     else if (event is VerifyPasswordResetCodeSubmittedEvent) {
      await _onVerifyPasswordResetCodeSubmitted(event, _emit);
    }     else if (event is ResetPasswordSubmittedEvent) {
      await _onResetPasswordSubmitted(event, _emit);
    }     else if (event is ChangePasswordSubmittedEvent) {
      await _onChangePasswordSubmitted(event, _emit);
    }     else if (event is SignOutEvent) {
      await _onSignOut(event, _emit);
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await authRepository.getCurrentUser();

      if (user == null) {
        emit(const Unauthenticated());
        return;
      }

      emit(
        Authenticated(
          user,
        ),
      );
    } catch (error) {
      emit(
        AuthError(
          _messageFromError(
            error,
          ),
        ),
      );
    }
  }

  Future<void> _onSignInSubmitted(
    SignInSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await authRepository.signInWithEmailPassword(
        email: event.email,
        password: event.password,
      );

      emit(
        Authenticated(
          user,
        ),
      );
    } catch (error) {
      if (error is ServerException &&
          error.code == 'email_verification_required') {
        final email =
            error.getString('email') ?? event.email.trim().toLowerCase();

        emit(
          EmailVerificationRequired(
            email: email,
            message: error.message,
            emailSent: false,
          ),
        );

        return;
      }

      emit(
        AuthError(
          _messageFromError(
            error,
          ),
        ),
      );
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await authRepository.registerUser(
        fullName: event.fullName,
        email: event.email,
        phone: event.phone,
        password: event.password,
      );

      if (result.requiresEmailVerification) {
        emit(
          EmailVerificationRequired(
            email: result.email,
            message: result.message,
            emailSent: result.emailSent,
          ),
        );

        return;
      }

      emit(
        AuthError(
          result.message,
        ),
      );
    } catch (error) {
      emit(
        AuthError(
          _messageFromError(
            error,
          ),
        ),
      );
    }
  }

  Future<void> _onVerifyEmailSubmitted(
    VerifyEmailSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await authRepository.verifyEmail(
        email: event.email,
        code: event.code,
      );

      emit(
        Authenticated(
          user,
        ),
      );
    } catch (error) {
      emit(
        AuthError(
          _messageFromError(
            error,
          ),
        ),
      );
    }
  }

  Future<void> _onResendEmailVerification(
    ResendEmailVerificationEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final message = await authRepository.resendEmailVerification(
        email: event.email,
      );

      emit(
        EmailVerificationCodeResent(
          email: event.email,
          message: message,
        ),
      );
    } catch (error) {
      emit(
        AuthError(
          _messageFromError(
            error,
          ),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Forgot Password
  // ---------------------------------------------------------------------------

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final email = event.email.trim().toLowerCase();

      final message = await authRepository.forgotPassword(
        email: email,
      );

      emit(
        PasswordResetCodeSent(
          email: email,
          message: message,
        ),
      );
    } catch (error) {
      emit(
        AuthError(
          _messageFromError(
            error,
          ),
        ),
      );
    }
  }

  Future<void> _onVerifyPasswordResetCodeSubmitted(
    VerifyPasswordResetCodeSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final email = event.email.trim().toLowerCase();

      final resetToken = await authRepository.verifyPasswordResetCode(
        email: email,
        code: event.code.trim(),
      );

      emit(
        PasswordResetCodeVerified(
          email: email,
          resetToken: resetToken,
        ),
      );
    } catch (error) {
      emit(
        AuthError(
          _messageFromError(
            error,
          ),
        ),
      );
    }
  }

  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final message = await authRepository.resetPassword(
        resetToken: event.resetToken,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );

      emit(
        PasswordResetSuccess(
          message: message,
        ),
      );
    } catch (error) {
      emit(
        AuthError(
          _messageFromError(
            error,
          ),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Change Password
  // ---------------------------------------------------------------------------

  Future<void> _onChangePasswordSubmitted(
    ChangePasswordSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final message = await authRepository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );

      emit(
        PasswordChangeSuccess(
          message: message,
        ),
      );
    } catch (error) {
      emit(
        AuthError(
          _messageFromError(
            error,
          ),
        ),
      );
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await authRepository.signOut();
    } finally {
      emit(
        const Unauthenticated(),
      );
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
