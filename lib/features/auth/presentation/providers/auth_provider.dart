import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/registration_result_entity.dart';
import '../../domain/entities/user_entity.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserEntity?>(AuthController.new);

/// Current authenticated session. Transient form operations use separate
/// providers so email/reset errors never discard an authenticated session.
class AuthController extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() =>
      ref.read(authRepositoryProvider).getCurrentUser();

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).verifyEmail(
        email: email,
        code: code,
      ),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).getCurrentUser(),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
      return null;
    });
  }
}

class RegistrationController extends AsyncNotifier<RegistrationResultEntity?> {
  @override
  Future<RegistrationResultEntity?> build() async => null;

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).registerUser(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      ),
    );
  }
}

final registrationControllerProvider =
    AsyncNotifierProvider<RegistrationController, RegistrationResultEntity?>(
  RegistrationController.new,
);

class PasswordRecoveryController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  Future<void> sendCode(String email) =>
      _execute(() => ref.read(authRepositoryProvider).forgotPassword(email: email));

  Future<void> resendEmailVerification(String email) => _execute(
        () => ref.read(authRepositoryProvider).resendEmailVerification(
          email: email,
        ),
      );

  Future<void> verifyResetCode({
    required String email,
    required String code,
  }) =>
      _execute(() => ref.read(authRepositoryProvider).verifyPasswordResetCode(
            email: email,
            code: code,
          ));

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) =>
      _execute(() => ref.read(authRepositoryProvider).resetPassword(
            resetToken: resetToken,
            newPassword: newPassword,
            confirmPassword: confirmPassword,
          ));

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) =>
      _execute(() => ref.read(authRepositoryProvider).changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
            confirmPassword: confirmPassword,
          ));

  Future<void> _execute(Future<String> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
  }
}

final passwordRecoveryControllerProvider =
    AsyncNotifierProvider<PasswordRecoveryController, String?>(
  PasswordRecoveryController.new,
);
