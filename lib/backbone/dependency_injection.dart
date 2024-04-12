import 'package:get_it/get_it.dart';
import 'package:webitel_sdk/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk/data/service_impl/chat_service_impl.dart';
import 'package:webitel_sdk/data/service_impl/local_storage_service_impl.dart';
import 'package:webitel_sdk/domain/service/chat_service.dart';
import 'package:webitel_sdk/domain/service/local_storage_service.dart';
import 'package:webitel_sdk/domain/usecase/fetch_device_id_usecase.dart';
import 'package:webitel_sdk/domain/usecase/send_dialog_message_usecase.dart';
import 'package:webitel_sdk/presentation/bloc/chat/chat_bloc.dart';
import 'package:webitel_sdk/presentation/device_info/device_info_bloc.dart';

final GetIt locator = GetIt.instance;

Future<void> registerDi() async {
  //Gateway
  locator.registerLazySingleton<SharedPreferencesGateway>(
      () => SharedPreferencesGateway());

  //Service
  locator.registerLazySingleton<ChatService>(() => ChatServiceImpl());
  locator.registerLazySingleton<LocalStorageService>(
      () => LocalStorageServiceImpl(locator.get()));

  //Use case
  locator.registerLazySingleton<SendDialogMessageUseCase>(
      () => SendDialogMessageImplUseCase(locator.get()),
      instanceName: "SendDialogMessageUseCase");
  locator.registerLazySingleton<FetchDeviceIdUseCase>(
      () => FetchDeviceIdUseCaseImplUseCase(locator.get()),
      instanceName: "FetchDeviceIdUseCase");

  //BloC
  locator.registerLazySingleton<ChatBloc>(
    () => ChatBloc(
      locator<SendDialogMessageUseCase>(
          instanceName: "SendDialogMessageUseCase"),
    ),
  );
  locator.registerLazySingleton<DeviceInfoBloc>(
    () => DeviceInfoBloc(
      locator<FetchDeviceIdUseCase>(instanceName: "FetchDeviceIdUseCase"),
    ),
  );
}
