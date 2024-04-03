import 'package:get_it/get_it.dart';
import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/data/service_impl/auth_service_impl.dart';
import 'package:webitel_sdk_package/src/domain/services/auth_service.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/init_grpc_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/ping_usecase.dart';

final GetIt locator = GetIt.instance;

Future<void> registerServices() async {
  //Gateway
  if (!locator.isRegistered<GrpcGateway>(instanceName: "GrpcGateway")) {
    locator.registerLazySingleton<GrpcGateway>(() => GrpcGateway());
  }

  //Service
  if (!locator.isRegistered<AuthService>(instanceName: "AuthServiceImpl")) {
    locator.registerLazySingleton<AuthService>(
        () => AuthServiceImpl(locator.get()));
  }

  //Usecase
  if (!locator.isRegistered<InitUseCase>(instanceName: "InitUseCase")) {
    locator.registerLazySingleton<InitUseCase>(
        () => GrpcInitUseCase(locator.get()),
        instanceName: "InitUseCase");
  }

  if (!locator.isRegistered<PingUseCase>(instanceName: "PingUseCase")) {
    locator.registerLazySingleton<PingUseCase>(
        () => GrpcPingUseCase(locator.get()),
        instanceName: "PingUseCase");
  }
}
