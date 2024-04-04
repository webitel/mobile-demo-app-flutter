abstract interface class GrpcChatService {
  Future<String> ping({required List<int> echo});

  Future<String> connectToGrpcChannel({
    required String deviceId,
    required String clientToken,
    required String accessToken,
  });

  Future<void> fetchDialogs();

  Future<void> fetchUpdates();

  Future<void> sendMessage();
}
