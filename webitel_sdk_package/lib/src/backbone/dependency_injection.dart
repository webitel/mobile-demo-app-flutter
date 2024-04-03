import 'package:get_it/get_it.dart';
import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/data/service_impl/auth_service_impl.dart';
import 'package:webitel_sdk_package/src/domain/services/auth_service.dart';

final GetIt locator = GetIt.instance;

void registerServices() {
  if (!locator.isRegistered<GrpcGateway>(instanceName: "GrpcGateway")) {
    locator.registerLazySingleton<GrpcGateway>(() => GrpcGateway(),
        instanceName: "GrpcGateway");
  }

  if (!locator.isRegistered<AuthService>(instanceName: "AuthServiceImpl")) {
    locator.registerSingleton<AuthService>(
      AuthServiceImpl(locator.get<GrpcGateway>(instanceName: "GrpcGateway")),
      instanceName: "AuthServiceImpl",
    );
  }
}
