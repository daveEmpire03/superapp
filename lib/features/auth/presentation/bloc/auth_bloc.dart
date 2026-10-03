import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(
      _onCheckAuthStatus,
    );

    on<SignInSubmittedEvent>(
      _onSignInSubmitted,
    );

    on<RegisterSubmittedEvent>(
      _onRegisterSubmitted,
    );

    on<VerifyEmailSubmittedEvent>(
      _onVerifyEmailSubmitted,
    );

    on<ResendEmailVerificationEvent>(
      _onResendEmailVerification,
    );

    on<ForgotPasswordSubmittedEvent>(
      _onForgotPasswordSubmitted,
    );

    on<VerifyPasswordResetCodeSubmittedEvent>(
      _onVerifyPasswordResetCodeSubmitted,
    );

    on<ResetPasswordSubmittedEvent>(
      _onResetPasswordSubmitted,
    );

    on<ChangePasswordSubmittedEvent>(
      _onChangePasswordSubmitted,
    );

    on<SignOutEvent>(
      _onSignOut,
    );
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
