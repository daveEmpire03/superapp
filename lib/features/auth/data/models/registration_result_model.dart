import '../../../../core/error/exceptions.dart';
import '../../domain/entities/registration_result_entity.dart';
import 'user_model.dart';

class RegistrationResultModel extends RegistrationResultEntity {
  const RegistrationResultModel({
    required super.message,
    required super.requiresEmailVerification,
    required super.email,
    required super.emailSent,
    required UserModel super.user,
  });

  factory RegistrationResultModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final userJson = json['user'];

    if (userJson is! Map) {
      throw const ServerException(
        message: 'Registration response did not contain user information.',
      );
    }

    final email = json['email']?.toString().trim() ?? '';

    if (email.isEmpty) {
      throw const ServerException(
        message: 'Registration response did not contain an email address.',
      );
    }

    return RegistrationResultModel(
      message: json['message']?.toString() ?? 'Account created successfully.',
      requiresEmailVerification: json['requires_email_verification'] == true,
      email: email,
      emailSent: json['email_sent'] == true,
      user: UserModel.fromJson(
        Map<String, dynamic>.from(
          userJson,
        ),
      ),
    );
  }
}
