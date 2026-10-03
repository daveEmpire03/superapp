import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../error/exceptions.dart';
import '../storage/auth_token_storage.dart';
import 'api_endpoints.dart';

class DioClient {
  DioClient({
    required AuthTokenStorage tokenStorage,
    Dio? customDio,
  })  : _tokenStorage = tokenStorage,
        dio = customDio ??
            Dio(
              BaseOptions(
                baseUrl: ApiEndpoints.baseUrl,
                connectTimeout: const Duration(
                  milliseconds: ApiEndpoints.connectTimeoutMs,
                ),
                sendTimeout: const Duration(
                  milliseconds: ApiEndpoints.sendTimeoutMs,
                ),
                receiveTimeout: const Duration(
                  milliseconds: ApiEndpoints.receiveTimeoutMs,
                ),
                headers: const {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    _configureInterceptors();
  }

  final Dio dio;

  final AuthTokenStorage _tokenStorage;

  Completer<String?>? _refreshCompleter;

  void _configureInterceptors() {
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (
          options,
          handler,
        ) async {
          if (!_isPublicAuthEndpoint(options.path)) {
            final accessToken = await _tokenStorage.getAccessToken();

            if (accessToken != null && accessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $accessToken';
            }
          }

          handler.next(options);
        },
        onError: (
          error,
          handler,
        ) async {
          final requestOptions = error.requestOptions;

          final shouldRefresh = error.response?.statusCode == 401 &&
              requestOptions.extra['bokku_refresh_attempted'] != true &&
              !_isPublicAuthEndpoint(
                requestOptions.path,
              ) &&
              !_isRefreshEndpoint(
                requestOptions.path,
              );

          if (!shouldRefresh) {
            handler.next(error);
            return;
          }

          final refreshToken = await _tokenStorage.getRefreshToken();

          if (refreshToken == null || refreshToken.isEmpty) {
            await _tokenStorage.clearTokens();

            handler.next(error);
            return;
          }

          final newAccessToken = await _refreshAccessToken();

          if (newAccessToken == null || newAccessToken.isEmpty) {
            await _tokenStorage.clearTokens();

            handler.next(error);
            return;
          }

          requestOptions.extra['bokku_refresh_attempted'] = true;

          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          try {
            final response = await dio.fetch<dynamic>(
              requestOptions,
            );

            handler.resolve(response);
          } on DioException catch (retryError) {
            handler.next(retryError);
          }
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          compact: true,
        ),
      );
    }
  }

  bool _isPublicAuthEndpoint(
    String path,
  ) {
    return path.contains(
          ApiEndpoints.login,
        ) ||
        path.contains(
          ApiEndpoints.register,
        ) ||
        path.contains(
          ApiEndpoints.refreshToken,
        ) ||
        path.contains(
          ApiEndpoints.verifyEmail,
        ) ||
        path.contains(
          ApiEndpoints.resendEmailVerification,
        ) ||
        path.contains(
          ApiEndpoints.forgotPassword,
        ) ||
        path.contains(
          ApiEndpoints.verifyPasswordResetCode,
        ) ||
        path.contains(
          ApiEndpoints.resetPassword,
        );
  }

  bool _isRefreshEndpoint(
    String path,
  ) {
    return path.contains(
      ApiEndpoints.refreshToken,
    );
  }

  Future<String?> _refreshAccessToken() async {
    final existingRefresh = _refreshCompleter;

    if (existingRefresh != null) {
      return existingRefresh.future;
    }

    final completer = Completer<String?>();

    _refreshCompleter = completer;

    try {
      final currentRefreshToken = await _tokenStorage.getRefreshToken();

      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        await _tokenStorage.clearTokens();

        completer.complete(null);

        return await completer.future;
      }

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(
            milliseconds: ApiEndpoints.connectTimeoutMs,
          ),
          sendTimeout: const Duration(
            milliseconds: ApiEndpoints.sendTimeoutMs,
          ),
          receiveTimeout: const Duration(
            milliseconds: ApiEndpoints.receiveTimeoutMs,
          ),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await refreshDio.post<dynamic>(
        ApiEndpoints.refreshToken,
        data: {
          'refresh': currentRefreshToken,
        },
      );

      final data = response.data;

      if (data is! Map) {
        await _tokenStorage.clearTokens();

        completer.complete(null);

        return await completer.future;
      }

      final accessToken = data['access']?.toString();

      if (accessToken == null || accessToken.isEmpty) {
        await _tokenStorage.clearTokens();

        completer.complete(null);

        return await completer.future;
      }

      final rotatedRefreshToken = data['refresh']?.toString();

      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken:
            rotatedRefreshToken != null && rotatedRefreshToken.isNotEmpty
                ? rotatedRefreshToken
                : currentRefreshToken,
      );

      completer.complete(
        accessToken,
      );

      return await completer.future;
    } catch (_) {
      await _tokenStorage.clearTokens();

      if (!completer.isCompleted) {
        completer.complete(null);
      }

      return completer.future;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      throw _handleDioError(
        error,
      );
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      throw _handleDioError(
        error,
      );
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      throw _handleDioError(
        error,
      );
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      throw _handleDioError(
        error,
      );
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      throw _handleDioError(
        error,
      );
    }
  }

  Exception _handleDioError(
    DioException error,
  ) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkException(
        message:
            'Network connection issue. Please check your internet connection.',
      );
    }

    final response = error.response;

    if (response != null) {
      final responseData = _toStringDynamicMap(
        response.data,
      );

      return ServerException(
        message: _extractServerMessage(
          response.data,
        ),
        statusCode: response.statusCode,
        code: _extractServerCode(
          response.data,
        ),
        data: responseData,
      );
    }

    return ServerException(
      message: error.message ?? 'Unknown error occurred.',
    );
  }

  Map<String, dynamic>? _toStringDynamicMap(
    dynamic data,
  ) {
    if (data is! Map) {
      return null;
    }

    try {
      return Map<String, dynamic>.from(
        data,
      );
    } catch (_) {
      return data.map(
        (
          key,
          value,
        ) {
          return MapEntry(
            key.toString(),
            value,
          );
        },
      );
    }
  }

  String? _extractServerCode(
    dynamic data,
  ) {
    if (data == null) {
      return null;
    }

    if (data is Map) {
      if (data.containsKey('code')) {
        final code = _extractFirstText(
          data['code'],
        );

        if (code != null) {
          return code;
        }
      }

      for (final value in data.values) {
        final nestedCode = _extractServerCode(
          value,
        );

        if (nestedCode != null) {
          return nestedCode;
        }
      }
    }

    if (data is List) {
      for (final value in data) {
        final nestedCode = _extractServerCode(
          value,
        );

        if (nestedCode != null) {
          return nestedCode;
        }
      }
    }

    return null;
  }

  String _extractServerMessage(
    dynamic data,
  ) {
    if (data == null) {
      return 'An unexpected server error occurred.';
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    if (data is Map) {
      final message = _extractFirstText(
        data['message'],
      );

      if (message != null) {
        return message;
      }

      final detail = _extractFirstText(
        data['detail'],
      );

      if (detail != null) {
        return detail;
      }

      for (final entry in data.entries) {
        if (entry.key.toString() == 'code') {
          continue;
        }

        final value = entry.value;

        final text = _extractFirstText(
          value,
        );

        if (text != null) {
          return text;
        }

        if (value is Map || value is List) {
          final nestedMessage = _extractServerMessage(
            value,
          );

          if (nestedMessage != 'An unexpected server error occurred.') {
            return nestedMessage;
          }
        }
      }
    }

    if (data is List && data.isNotEmpty) {
      for (final value in data) {
        final text = _extractFirstText(
          value,
        );

        if (text != null) {
          return text;
        }

        if (value is Map || value is List) {
          final nestedMessage = _extractServerMessage(
            value,
          );

          if (nestedMessage != 'An unexpected server error occurred.') {
            return nestedMessage;
          }
        }
      }
    }

    return 'An unexpected server error occurred.';
  }

  String? _extractFirstText(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      final text = value.trim();

      return text.isEmpty ? null : text;
    }

    if (value is List && value.isNotEmpty) {
      for (final item in value) {
        final text = _extractFirstText(
          item,
        );

        if (text != null) {
          return text;
        }
      }

      return null;
    }

    return null;
  }
}
