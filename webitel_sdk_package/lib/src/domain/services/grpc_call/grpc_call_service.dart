abstract interface class GrpcCallService {
  Future<void> makeCall();

  Future<void> endCall();

  Future<void> holdCall();
}
