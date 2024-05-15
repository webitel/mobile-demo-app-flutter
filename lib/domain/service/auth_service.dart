import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/domain/entity/response_entity.dart';

abstract interface class AuthService {
  Future<ResponseEntity> login({required PortalClient client});

  Future<PortalClient> initClient();

  Future<void> logout({required PortalClient client});

  Future<void> registerDevice({
    required PortalClient client,
    required String pushToken,
  });
}
