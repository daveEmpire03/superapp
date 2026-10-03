import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(
    this.user,
  );

  @override
  List<Object?> get props => [
        user,
      ];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

// -----------------------------------------------------------------------------
// Email Verification
// -----------------------------------------------------------------------------

class EmailVerificationRequired extends AuthState {
  final String email;
  final String message;
  final bool emailSent;

  const EmailVerificationRequired({
    required this.email,
    required this.message,
    required this.emailSent,
  });

  @override
  List<Object?> get props => [
        email,
        message,
        emailSent,
      ];
}

class EmailVerificationCodeResent extends AuthState {
  final String email;
  final String message;

  const EmailVerificationCodeResent({
    required this.email,
    required this.message,
  });

  @override
  List<Object?> get props => [
        email,
        message,
      ];
}

// -----------------------------------------------------------------------------
// Password Recovery
// -----------------------------------------------------------------------------

class PasswordResetCodeSent extends AuthState {
  final String email;
  final String message;

  const PasswordResetCodeSent({
    required this.email,
    required this.message,
  });

  @override
  List<Object?> get props => [
        email,
        message,
      ];
}

class PasswordResetCodeVerified extends AuthState {
  final String email;
  final String resetToken;

  const PasswordResetCodeVerified({
    required this.email,
    required this.resetToken,
  });

  @override
  List<Object?> get props => [
        email,
        resetToken,
      ];
}

class PasswordResetSuccess extends AuthState {
  final String message;

  const PasswordResetSuccess({
    required this.message,
  });

  @override
  List<Object?> get props => [
        message,
      ];
}

class PasswordChangeSuccess extends AuthState {
  final String message;

  const PasswordChangeSuccess({
    required this.message,
  });

  @override
  List<Object?> get props => [
        message,
      ];
}
// -----------------------------------------------------------------------------
// Error
// -----------------------------------------------------------------------------

class AuthError extends AuthState {
  final String message;

  const AuthError(
    this.message,
  );

  @override
  List<Object?> get props => [
        message,
      ];
}
