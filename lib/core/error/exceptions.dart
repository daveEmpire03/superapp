class ServerException implements Exception {
  final String message;
  final int? statusCode;

  /// Machine-readable error code returned by the backend.
  ///
  /// Examples:
  /// - email_verification_required
  /// - verification_cooldown
  /// - invalid_verification_code
  /// - password_reset_token_expired
  final String? code;

  /// Original structured response returned by the backend.
  ///
  /// This allows higher layers to safely retrieve additional fields
  /// such as `email` without depending directly on Dio.
  final Map<String, dynamic>? data;

  const ServerException({
    this.message = 'Server Exception',
    this.statusCode,
    this.code,
    this.data,
  });

  String? getString(
    String key,
  ) {
    final value = _findValue(
      data,
      key,
    );

    if (value == null) {
      return null;
    }

    if (value is String) {
      final text = value.trim();

      return text.isEmpty ? null : text;
    }

    if (value is List && value.isNotEmpty) {
      final text = value.first?.toString().trim();

      if (text == null || text.isEmpty) {
        return null;
      }

      return text;
    }

    final text = value.toString().trim();

    return text.isEmpty ? null : text;
  }

  Object? _findValue(
    Object? source,
    String key,
  ) {
    if (source is Map) {
      if (source.containsKey(key)) {
        return source[key];
      }

      for (final value in source.values) {
        final found = _findValue(
          value,
          key,
        );

        if (found != null) {
          return found;
        }
      }
    }

    if (source is List) {
      for (final value in source) {
        final found = _findValue(
          value,
          key,
        );

        if (found != null) {
          return found;
        }
      }
    }

    return null;
  }

  @override
  String toString() {
    return 'ServerException: $message '
        '(statusCode: $statusCode, code: $code)';
  }
}

class CacheException implements Exception {
  final String message;

  const CacheException({
    this.message = 'Cache Exception',
  });

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({
    this.message = 'Network connection failed',
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Describes why device location could not be obtained.
enum LocationExceptionType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  unavailable,
}

class LocationException implements Exception {
  final LocationExceptionType type;
  final String message;

  const LocationException({
    required this.type,
    required this.message,
  });

  @override
  String toString() => 'LocationException: $message';
}
