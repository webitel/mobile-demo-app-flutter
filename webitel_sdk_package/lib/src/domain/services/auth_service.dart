abstract class AuthService {
  Future<void> initGrpc();
  Future<String> ping();
}
