import 'package:get_it/get_it.dart';
import 'package:webitel_sdk/data/gateway/file_picker_gateway.dart';
import 'package:webitel_sdk/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk/data/service_impl/auth_service_impl.dart';
import 'package:webitel_sdk/data/service_impl/chat_service_impl.dart';
import 'package:webitel_sdk/database/database_provider.dart';
import 'package:webitel_sdk/domain/service/auth_service.dart';
import 'package:webitel_sdk/domain/service/chat_service.dart';
import 'package:webitel_sdk/presentation/bloc/auth/auth_bloc.dart';
import 'package:webitel_sdk/presentation/bloc/chat/chat_bloc.dart';

final GetIt locator = GetIt.instance;

Future<void> registerDi() async {
  //Gateway
  locator.registerLazySingleton<SharedPreferencesGateway>(
      () => SharedPreferencesGateway());
  locator.registerLazySingleton<DatabaseProvider>(() => DatabaseProvider());
  locator.registerLazySingleton<FilePickerGateway>(() => FilePickerGateway());

  //Service
  locator.registerLazySingleton<ChatService>(
      () => ChatServiceImpl(locator.get(), locator.get()));
  locator
      .registerLazySingleton<AuthService>(() => AuthServiceImpl(locator.get()));

  //BloC
  locator.registerLazySingleton<ChatBloc>(
    () => ChatBloc(locator<ChatService>()),
  );
  locator.registerLazySingleton<AuthBloc>(
    () => AuthBloc(locator<AuthService>()),
  );
}
