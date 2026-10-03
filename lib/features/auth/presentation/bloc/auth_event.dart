import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class SignInSubmittedEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInSubmittedEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [
        email,
        password,
      ];
}

class RegisterSubmittedEvent extends AuthEvent {
  final String fullName;
  final String email;
  final String phone;
  final String password;

  const RegisterSubmittedEvent({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        phone,
        password,
      ];
}

class VerifyEmailSubmittedEvent extends AuthEvent {
  final String email;
  final String code;

  const VerifyEmailSubmittedEvent({
    required this.email,
    required this.code,
  });

  @override
  List<Object?> get props => [
        email,
        code,
      ];
}

class ResendEmailVerificationEvent extends AuthEvent {
  final String email;

  const ResendEmailVerificationEvent({
    required this.email,
  });

  @override
  List<Object?> get props => [
        email,
      ];
}

// -----------------------------------------------------------------------------
// Password Recovery
// -----------------------------------------------------------------------------

class ForgotPasswordSubmittedEvent extends AuthEvent {
  final String email;

  const ForgotPasswordSubmittedEvent({
    required this.email,
  });

  @override
  List<Object?> get props => [
        email,
      ];
}

class VerifyPasswordResetCodeSubmittedEvent extends AuthEvent {
  final String email;
  final String code;

  const VerifyPasswordResetCodeSubmittedEvent({
    required this.email,
    required this.code,
  });

  @override
  List<Object?> get props => [
        email,
        code,
      ];
}

class ResetPasswordSubmittedEvent extends AuthEvent {
  final String resetToken;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordSubmittedEvent({
    required this.resetToken,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [
        resetToken,
        newPassword,
        confirmPassword,
      ];
}

class ChangePasswordSubmittedEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordSubmittedEvent({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [
        currentPassword,
        newPassword,
        confirmPassword,
      ];
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}
