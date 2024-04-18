import 'package:get_it/get_it.dart';
import 'package:webitel_sdk/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk/data/service_impl/chat_service_impl.dart';
import 'package:webitel_sdk/data/service_impl/database_service_impl.dart';
import 'package:webitel_sdk/data/service_impl/local_storage_service_impl.dart';
import 'package:webitel_sdk/database/database_provider.dart';
import 'package:webitel_sdk/domain/service/chat_service.dart';
import 'package:webitel_sdk/domain/service/data_base_service.dart';
import 'package:webitel_sdk/domain/service/local_storage_service.dart';
import 'package:webitel_sdk/domain/usecase/database/fetch_messages_by_chat_id.dart';
import 'package:webitel_sdk/domain/usecase/database/write_messages_to_database_usecase.dart';
import 'package:webitel_sdk/domain/usecase/fetch_device_id_usecase.dart';
import 'package:webitel_sdk/domain/usecase/send_dialog_message_usecase.dart';
import 'package:webitel_sdk/presentation/bloc/chat/chat_bloc.dart';
import 'package:webitel_sdk/presentation/bloc/device_info/device_info_bloc.dart';

final GetIt locator = GetIt.instance;

Future<void> registerDi() async {
  //Gateway
  locator.registerLazySingleton<SharedPreferencesGateway>(
      () => SharedPreferencesGateway());
  locator.registerLazySingleton<DatabaseProvider>(() => DatabaseProvider());

  //Service
  locator.registerLazySingleton<ChatService>(() => ChatServiceImpl());
  locator.registerLazySingleton<DatabaseService>(
      () => DatabaseServiceImpl(locator.get()));
  locator.registerLazySingleton<LocalStorageService>(
      () => LocalStorageServiceImpl(locator.get()));

  //Use case
  locator.registerLazySingleton<SendDialogMessageUseCase>(
      () => SendDialogMessageImplUseCase(locator.get()),
      instanceName: "SendDialogMessageUseCase");
  locator.registerLazySingleton<FetchMessagesByChatIdUseCase>(
      () => FetchMessagesByChatIdImplUseCase(locator.get()),
      instanceName: "FetchMessagesByChatIdUseCase");
  locator.registerLazySingleton<WriteMessageToDatabaseUseCase>(
      () => WriteMessageToDatabaseImplUseCase(locator.get()),
      instanceName: "WriteMessageToDatabaseUseCase");
  locator.registerLazySingleton<FetchDeviceIdUseCase>(
      () => FetchDeviceIdUseCaseImplUseCase(locator.get()),
      instanceName: "FetchDeviceIdUseCase");

  //BloC
  locator.registerLazySingleton<ChatBloc>(
    () => ChatBloc(
      locator<SendDialogMessageUseCase>(
          instanceName: "SendDialogMessageUseCase"),
      locator<WriteMessageToDatabaseUseCase>(
          instanceName: "WriteMessageToDatabaseUseCase"),
      locator<FetchMessagesByChatIdUseCase>(
          instanceName: "FetchMessagesByChatIdUseCase"),
    ),
  );
  locator.registerLazySingleton<DeviceInfoBloc>(
    () => DeviceInfoBloc(
      locator<FetchDeviceIdUseCase>(instanceName: "FetchDeviceIdUseCase"),
    ),
  );
}
