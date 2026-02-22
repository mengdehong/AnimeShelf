import 'dart:developer';

import 'package:anime_shelf/core/exceptions/api_exception.dart';
import 'package:dio/dio.dart';

/// Pre-configured Dio client for Bangumi API v0.
///
/// Includes User-Agent header, JSON accept, and exponential
/// backoff retry interceptor (1s → 2s → 4s, max 3 attempts).
class BangumiClient {
  static const _baseUrl = 'https://api.bgm.tv';
  static const _userAgent =
      'AnimeShelf/1.0 (https://github.com/wenmou/animeshelf)';
  static const _maxRetries = 3;

  late final Dio _dio;

  BangumiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'User-Agent': _userAgent, 'Accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(_retryInterceptor());
  }

  Dio get dio => _dio;

  InterceptorsWrapper _retryInterceptor() {
    return InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        final shouldRetry = _isRetryable(error);
        final extra = error.requestOptions.extra;
        final retryCount = (extra['retryCount'] as int?) ?? 0;

        if (shouldRetry && retryCount < _maxRetries) {
          final delay = Duration(seconds: 1 << retryCount);
          log(
            'Retrying request (${retryCount + 1}/$_maxRetries) '
            'after ${delay.inSeconds}s: ${error.requestOptions.path}',
          );
          await Future<void>.delayed(delay);

          error.requestOptions.extra['retryCount'] = retryCount + 1;
          try {
            final response = await _dio.fetch(error.requestOptions);
            return handler.resolve(response);
          } on DioException catch (e) {
            return handler.next(e);
          }
        }

        return handler.next(error);
      },
    );
  }

  bool _isRetryable(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return true;
    }
    final statusCode = error.response?.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return true;
    }
    return false;
  }

  /// Wraps Dio errors into domain [ApiException]s.
  Never throwApiException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      throw NetworkTimeoutException(originalError: error);
    }
    if (error.type == DioExceptionType.connectionError) {
      throw NoConnectionException(originalError: error);
    }
    throw ApiException(
      message: error.message ?? 'Unknown API error',
      statusCode: error.response?.statusCode,
      originalError: error,
    );
  }
}
