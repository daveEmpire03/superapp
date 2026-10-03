import '../entities/registration_result_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<RegistrationResultEntity> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  Future<UserEntity> verifyEmail({
    required String email,
    required String code,
  });

  Future<String> resendEmailVerification({
    required String email,
  });

  Future<String> forgotPassword({
    required String email,
  });

  Future<String> verifyPasswordResetCode({
    required String email,
    required String code,
  });

  Future<String> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  });

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<UserEntity?> getCurrentUser();

  Future<void> signOut();
}
