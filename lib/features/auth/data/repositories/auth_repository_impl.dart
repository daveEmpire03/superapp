import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/auth_token_storage.dart';
import '../../domain/entities/registration_result_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthTokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<UserEntity> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final session = await remoteDataSource.signIn(
      email: email,
      password: password,
    );

    await tokenStorage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );

    return session.user;
  }

  @override
  Future<RegistrationResultEntity> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) {
    return remoteDataSource.register(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
    );
  }

  @override
  Future<UserEntity> verifyEmail({
    required String email,
    required String code,
  }) async {
    final session = await remoteDataSource.verifyEmail(
      email: email,
      code: code,
    );

    await tokenStorage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );

    return session.user;
  }

  @override
  Future<String> resendEmailVerification({
    required String email,
  }) {
    return remoteDataSource.resendEmailVerification(
      email: email,
    );
  }

  @override
  Future<String> forgotPassword({
    required String email,
  }) {
    return remoteDataSource.forgotPassword(
      email: email,
    );
  }

  @override
  Future<String> verifyPasswordResetCode({
    required String email,
    required String code,
  }) {
    return remoteDataSource.verifyPasswordResetCode(
      email: email,
      code: code,
    );
  }

  @override
  Future<String> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) {
    return remoteDataSource.resetPassword(
      resetToken: resetToken,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  @override
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final message = await remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    // Force re-authentication on this device after a password change.
    await tokenStorage.clearTokens();

    return message;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final hasTokens = await tokenStorage.hasTokens();

    if (!hasTokens) {
      return null;
    }

    try {
      return await remoteDataSource.getProfile();
    } on ServerException catch (error) {
      if (error.statusCode == 401) {
        await tokenStorage.clearTokens();
        return null;
      }

      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await tokenStorage.clearTokens();
  }
}
