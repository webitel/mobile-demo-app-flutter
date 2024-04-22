import 'package:webitel_portal_sdk/src/domain/usecase/chat_list/fetch_dialogs_usecase.dart';
import 'package:webitel_portal_sdk/src/injection/injection.dart';

class ChatListHandler {
  late final FetchDialogsUseCase _fetchDialogsUseCase;

  ChatListHandler() {
    _fetchDialogsUseCase = getIt.get<FetchDialogsUseCase>();
  }

  Future<void> fetchDialogs() async {
    await _fetchDialogsUseCase();
  }
}
