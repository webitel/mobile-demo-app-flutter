import 'package:webitel_sdk_package/src/backbone/injection/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_call/end_call_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_call/hold_call_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_call/make_call_usecase.dart';

class DialogCallHandler {
  late MakeCallUseCase _makeCallUseCase;
  late HoldCallUseCase _holdCallUseCase;
  late EndCallUseCase _endCallUseCase;

  DialogCallHandler() {
    _makeCallUseCase =
        locator.get<MakeCallUseCase>(instanceName: "MakeCallUseCase");
    _holdCallUseCase =
        locator.get<HoldCallUseCase>(instanceName: "HoldCallUseCase");
    _endCallUseCase =
        locator.get<EndCallUseCase>(instanceName: "EndCallUseCase");
  }

  Future<void> makeCall() async {
    return await _makeCallUseCase();
  }

  Future<void> holdCall() async {
    return await _holdCallUseCase();
  }

  Future<void> endCall() async {
    return await _endCallUseCase();
  }
}
