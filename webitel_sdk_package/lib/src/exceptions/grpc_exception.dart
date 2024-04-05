class GrpcException implements Exception {
  final String message;
  final Exception? thrownException;

  GrpcException({required this.message, this.thrownException});

  @override
  String toString() {
    return message;
  }
}
