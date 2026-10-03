import '../../../../core/error/exceptions.dart';
import 'user_model.dart';

class AuthSessionModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthSessionModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthSessionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final accessToken = json['access']?.toString();
    final refreshToken = json['refresh']?.toString();
    final userJson = json['user'];

    if (accessToken == null || accessToken.isEmpty) {
      throw const ServerException(
        message: 'Login response did not contain an access token.',
      );
    }

    if (refreshToken == null || refreshToken.isEmpty) {
      throw const ServerException(
        message: 'Login response did not contain a refresh token.',
      );
    }

    if (userJson is! Map) {
      throw const ServerException(
        message: 'Login response did not contain user information.',
      );
    }

    return AuthSessionModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: UserModel.fromJson(
        Map<String, dynamic>.from(userJson),
      ),
    );
  }
}
