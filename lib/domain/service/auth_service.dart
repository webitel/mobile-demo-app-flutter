import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';

abstract interface class AuthService {
  Future<PortalResponse> login({required PortalClient client});

  Future<PortalClient> initClient();

  Future<void> logout({required PortalClient client});

  Future<void> registerDevice({
    required PortalClient client,
    required String pushToken,
  });

  Future<Stream<CallError>> listenToError({required PortalClient client});
}
