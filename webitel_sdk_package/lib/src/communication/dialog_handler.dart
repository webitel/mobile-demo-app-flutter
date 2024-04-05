import 'package:webitel_sdk_package/src/backbone/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/fetch_dialogs_usecase.dart';

class DialogHandler {
  late FetchDialogsUseCase _fetchDialogsUseCase;

  DialogHandler() {
    _fetchDialogsUseCase =
        locator.get<FetchDialogsUseCase>(instanceName: "FetchDialogsUseCase");
  }

  Future<void> fetchDialogs() async {
    return await _fetchDialogsUseCase();
  }
}
