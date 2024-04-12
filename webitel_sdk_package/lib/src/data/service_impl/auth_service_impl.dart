import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/domain/services/auth/auth_service.dart';
import 'package:webitel_sdk_package/src/generated/portal/account.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/auth.pb.dart';

class AuthServiceImpl implements AuthService {
  final GrpcGateway _grpcGateway;

  AuthServiceImpl(this._grpcGateway);

  @override
  Future<String> login() async {
    final request = TokenRequest(
      grantType: 'identity',
      responseType: ['user', 'token', 'chat'],
      appToken:
          '49sFBWUGEtlHz7iTWjIXIgRGnZXQ4dQZOy7fdM8AyffZ3oEQzNC5Noa6Aeem6BAw',
      identity: Identity(
        name: 'Volodia',
        sub: 'Test',
        iss: 'https://dev.webitel.com/portal',
      ),
    );

    final response = await _grpcGateway.customerClient.token(request);
    _grpcGateway.setAccessToken(response.accessToken);
    return response.accessToken;
  }
}
