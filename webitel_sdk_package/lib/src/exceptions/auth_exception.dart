class AuthException implements Exception {
  final String message;
  final Exception? thrownException;

  AuthException({required this.message, this.thrownException});

  @override
  String toString() {
    return message;
  }
}
