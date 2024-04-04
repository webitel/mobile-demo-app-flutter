import 'package:grpc/grpc.dart';
import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/domain/services/authorization/auth_service.dart';
import 'package:webitel_sdk_package/src/exceptions/auth_exception.dart';
import 'package:webitel_sdk_package/src/generated/portal/connect.pb.dart';

class AuthServiceImpl implements AuthService {
  final GrpcGateway _grpcGateway;

  AuthServiceImpl(this._grpcGateway);


  @override
  Future<String> ping() async {
    await _grpcGateway.init();
    final echoData = [1, 2, 3];
    final echo = Echo(data: echoData);

    CallOptions options = CallOptions(
      metadata: {'key1': 'value1'},
      timeout: Duration(seconds: 10),
      providers: [],
    );
    try {
      final res =
          await _grpcGateway.customerClient.ping(echo, options: options);
      return res.info_.messageName;
    } catch (error, _) {
      print('Error occurred: $error');
      return AuthException(message: error.toString()).message;
    }
  }
}
