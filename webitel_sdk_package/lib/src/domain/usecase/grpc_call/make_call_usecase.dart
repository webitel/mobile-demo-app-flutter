import 'package:webitel_sdk_package/src/domain/services/grpc_call/grpc_call_service.dart';

abstract interface class MakeCallUseCase {
  Future<void> call();
}

class MakeCallImplUseCase implements MakeCallUseCase {
  final GrpcCallService _grpcCallService;

  MakeCallImplUseCase(this._grpcCallService);

  @override
  Future<void> call() => _grpcCallService.makeCall();
}
