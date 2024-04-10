import 'package:webitel_sdk_package/src/backbone/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/fetch_dialogs_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/fetch_updates_usecase.dart';

class DialogHandler {
  late FetchDialogsUseCase _fetchDialogsUseCase;
  late FetchUpdatesUseCase _fetchUpdatesUseCase;

  DialogHandler() {
    _fetchDialogsUseCase =
        locator.get<FetchDialogsUseCase>(instanceName: "FetchDialogsUseCase");
    _fetchUpdatesUseCase =
        locator.get<FetchUpdatesUseCase>(instanceName: "FetchUpdatesUseCase");
  }

  Future<List<DialogMessageEntity>> fetchDialogs() async {
    return await _fetchDialogsUseCase();
  }

  Future<List<DialogMessageEntity>> fetchUpdates() async {
    return await _fetchUpdatesUseCase();
  }
}
