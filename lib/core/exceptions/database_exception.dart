/// Domain exception for local database errors.
class DatabaseException implements Exception {
  final String message;
  final dynamic originalError;

  const DatabaseException({required this.message, this.originalError});

  @override
  String toString() => 'DatabaseException: $message';
}
