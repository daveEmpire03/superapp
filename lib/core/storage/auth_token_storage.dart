import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStorage {
  AuthTokenStorage({
    required FlutterSecureStorage secureStorage,
  }) : _secureStorage = secureStorage;

  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'bokku_access_token';
  static const String _refreshTokenKey = 'bokku_refresh_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _secureStorage.write(
        key: _accessTokenKey,
        value: accessToken,
      ),
      _secureStorage.write(
        key: _refreshTokenKey,
        value: refreshToken,
      ),
    ]);
  }

  Future<void> saveAccessToken(
    String accessToken,
  ) async {
    await _secureStorage.write(
      key: _accessTokenKey,
      value: accessToken,
    );
  }

  Future<String?> getAccessToken() {
    return _secureStorage.read(
      key: _accessTokenKey,
    );
  }

  Future<String?> getRefreshToken() {
    return _secureStorage.read(
      key: _refreshTokenKey,
    );
  }

  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();

    return accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty;
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(
        key: _accessTokenKey,
      ),
      _secureStorage.delete(
        key: _refreshTokenKey,
      ),
    ]);
  }
}
