import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/domain/entity/response_entity.dart';

abstract interface class AuthService {
  Future<ResponseEntity> login({required Client client});

  Future<Client> initClient();

  Future<void> logout({required Client client});

  Future<void> registerDevice({
    required Client client,
    required String pushToken,
  });
}
