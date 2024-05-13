import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';

abstract interface class AuthService {
  Future<Client> login();
}
