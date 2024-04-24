import 'package:webitel_portal_sdk/src/domain/usecase/portal/exit_portal.dart';
import 'package:webitel_portal_sdk/src/injection/injection.dart';

class PortalHandler {
  late ExitPortalUseCase _exitPortalUsecase;

  PortalHandler() {
    _exitPortalUsecase = getIt.get<ExitPortalUseCase>();
  }

  Future<void> exitPortal() async {
    await _exitPortalUsecase();
  }
}
