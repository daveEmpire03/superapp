import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_session_model.dart';
import '../models/registration_result_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> signIn({
    required String email,
    required String password,
  });

  Future<RegistrationResultModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  Future<AuthSessionModel> verifyEmail({
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

  Future<UserModel> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({
    required this.dioClient,
  });

  @override
  Future<AuthSessionModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await dioClient.post<dynamic>(
      ApiEndpoints.login,
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const ServerException(
        message: 'Invalid login response from server.',
      );
    }

    return AuthSessionModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  @override
  Future<RegistrationResultModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await dioClient.post<dynamic>(
      ApiEndpoints.register,
      data: {
        'full_name': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'password': password,
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const ServerException(
        message: 'Invalid registration response from server.',
      );
    }

    return RegistrationResultModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  @override
  Future<AuthSessionModel> verifyEmail({
    required String email,
    required String code,
  }) async {
    final response = await dioClient.post<dynamic>(
      ApiEndpoints.verifyEmail,
      data: {
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const ServerException(
        message: 'Invalid email verification response from server.',
      );
    }

    return AuthSessionModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  @override
  Future<String> resendEmailVerification({
    required String email,
  }) async {
    final response = await dioClient.post<dynamic>(
      ApiEndpoints.resendEmailVerification,
      data: {
        'email': email.trim().toLowerCase(),
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const ServerException(
        message: 'Invalid verification resend response from server.',
      );
    }

    return data['message']?.toString() ??
        'A new verification code has been sent.';
  }

  @override
  Future<String> forgotPassword({
    required String email,
  }) async {
    final response = await dioClient.post<dynamic>(
      ApiEndpoints.forgotPassword,
      data: {
        'email': email.trim().toLowerCase(),
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const ServerException(
        message: 'Invalid forgot password response from server.',
      );
    }

    return data['message']?.toString() ??
        'If an account exists for this email, a password reset code has been sent.';
  }

  @override
  Future<String> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    final response = await dioClient.post<dynamic>(
      ApiEndpoints.verifyPasswordResetCode,
      data: {
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const ServerException(
        message: 'Invalid password reset verification response from server.',
      );
    }

    final resetToken = data['reset_token']?.toString().trim();

    if (resetToken == null || resetToken.isEmpty) {
      throw const ServerException(
        message: 'Password reset verification did not return a reset token.',
      );
    }

    return resetToken;
  }

  @override
  Future<String> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await dioClient.post<dynamic>(
      ApiEndpoints.resetPassword,
      data: {
        'reset_token': resetToken,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const ServerException(
        message: 'Invalid password reset response from server.',
      );
    }

    return data['message']?.toString() ??
        'Your password has been reset successfully.';
  }

  @override
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await dioClient.post<dynamic>(
      ApiEndpoints.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const ServerException(
        message: 'Invalid change password response from server.',
      );
    }

    return data['message']?.toString() ??
        'Your password has been changed successfully.';
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await dioClient.get<dynamic>(
      ApiEndpoints.userProfile,
    );

    final data = response.data;

    if (data is! Map) {
      throw const ServerException(
        message: 'Invalid profile response from server.',
      );
    }

    return UserModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }
}
