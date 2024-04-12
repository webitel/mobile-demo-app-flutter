abstract interface class InitializeService {
  Future<void> initGrpcClient({
    required String baseUrl,
    required String clientToken,
    String? deviceId,
  });
}
