import 'package:webitel_sdk_package/src/backbone/injection/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/usecase/chat_list/fetch_dialogs_usecase.dart';

class ChatListHandler {
  late final FetchDialogsUseCase _fetchDialogsUseCase;

  ChatListHandler() {
    _fetchDialogsUseCase =
        locator.get<FetchDialogsUseCase>(instanceName: "FetchDialogsUseCase");
  }

  Future<void> fetchDialogs() async {
    await _fetchDialogsUseCase();
  }
}
