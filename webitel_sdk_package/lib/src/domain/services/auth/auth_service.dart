abstract interface class AuthService {
  Future<void> logout();

  Future<void> registerDevice();
}
