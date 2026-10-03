import 'user_entity.dart';

class RegistrationResultEntity {
  final String message;
  final bool requiresEmailVerification;
  final String email;
  final bool emailSent;
  final UserEntity user;

  const RegistrationResultEntity({
    required this.message,
    required this.requiresEmailVerification,
    required this.email,
    required this.emailSent,
    required this.user,
  });
}
