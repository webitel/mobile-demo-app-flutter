import 'package:webitel_sdk_package/src/backbone/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/connect_to_grpc_channel_usecase.dart';

class GrpcStreamInitializer {
  late ConnectToGrpcChannelUseCase _connectToGrpcChannelUseCase;

  GrpcStreamInitializer() {
    _connectToGrpcChannelUseCase = locator.get<ConnectToGrpcChannelUseCase>(
        instanceName: "ConnectToGrpcChannelUseCase");
  }

  Future<void> connectToChannel() async {
    await _connectToGrpcChannelUseCase();
  }
}
