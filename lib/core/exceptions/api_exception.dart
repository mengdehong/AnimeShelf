/// Domain exception for Bangumi API errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thrown when a network request times out.
class NetworkTimeoutException extends ApiException {
  const NetworkTimeoutException({
    super.message = 'Request timed out',
    super.originalError,
  });
}

/// Thrown when there is no network connectivity.
class NoConnectionException extends ApiException {
  const NoConnectionException({
    super.message = 'No internet connection',
    super.originalError,
  });
}
