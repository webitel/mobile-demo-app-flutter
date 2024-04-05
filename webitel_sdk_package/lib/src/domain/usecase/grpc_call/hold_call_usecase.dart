import 'package:webitel_sdk_package/src/domain/services/grpc_call/grpc_call_service.dart';

abstract interface class HoldCallUseCase {
  Future<void> call();
}

class HoldCallImplUseCase implements HoldCallUseCase {
  final GrpcCallService _grpcCallService;

  HoldCallImplUseCase(this._grpcCallService);

  @override
  Future<void> call() => _grpcCallService.holdCall();
}
