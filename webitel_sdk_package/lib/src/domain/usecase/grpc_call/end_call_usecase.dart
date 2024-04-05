import 'package:webitel_sdk_package/src/domain/services/grpc_call/grpc_call_service.dart';

abstract interface class EndCallUseCase {
  Future<void> call();
}

class EndCallImplUseCase implements EndCallUseCase {
  final GrpcCallService _grpcCallService;

  EndCallImplUseCase(this._grpcCallService);

  @override
  Future<void> call() => _grpcCallService.endCall();
}
