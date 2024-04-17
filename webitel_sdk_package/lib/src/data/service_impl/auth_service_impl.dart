import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/domain/services/auth/auth_service.dart';
import 'package:webitel_sdk_package/src/generated/portal/customer.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/push.pb.dart';

class AuthServiceImpl implements AuthService {
  final GrpcGateway _grpcGateway;

  AuthServiceImpl(this._grpcGateway);

  @override
  Future<void> logout() async {
    await _grpcGateway.stub.logout(LogoutRequest());
  }

  @override
  Future<void> registerDevice() async {
    await _grpcGateway.stub
        .registerDevice(RegisterDeviceRequest(push: DevicePush()));
  }
}
