import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/domain/services/initialize/initialize_service.dart';

class InitializeServiceImpl implements InitializeService {
  final GrpcGateway _grpcGateway;

  InitializeServiceImpl(this._grpcGateway);

  @override
  Future<void> initGrpcClient() async {
    _grpcGateway.init();
  }
}
