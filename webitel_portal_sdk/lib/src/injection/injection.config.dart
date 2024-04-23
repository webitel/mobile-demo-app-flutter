// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../data/gateway/channel_status_listener.dart' as _i16;
import '../data/gateway/connect_listener_gateway.dart' as _i6;
import '../data/gateway/grpc_gateway.dart' as _i5;
import '../data/gateway/shared_preferences_gateway.dart' as _i4;
import '../data/service_impl/auth_service_impl.dart' as _i13;
import '../data/service_impl/chat_list_service_impl.dart' as _i19;
import '../data/service_impl/chat_service_impl.dart' as _i15;
import '../data/service_impl/connect_status_listener_service_impl.dart' as _i8;
import '../data/service_impl/error_service_impl.dart' as _i10;
import '../database/database.dart' as _i3;
import '../domain/services/auth_service.dart' as _i12;
import '../domain/services/chat_list_service.dart' as _i18;
import '../domain/services/connect_status_listener_service.dart' as _i7;
import '../domain/services/error_service.dart' as _i9;
import '../domain/services/grpc_chat_service.dart' as _i14;
import '../domain/usecase/auth/login_usecase.dart' as _i23;
import '../domain/usecase/auth/logout_usecase.dart' as _i25;
import '../domain/usecase/auth/register_device_usecase.dart' as _i27;
import '../domain/usecase/chat/fetch_message_updates.dart' as _i26;
import '../domain/usecase/chat/fetch_messages.dart' as _i22;
import '../domain/usecase/chat/listen_to_messages_usecase.dart' as _i20;
import '../domain/usecase/chat/send_message_usecase.dart' as _i21;
import '../domain/usecase/chat_list/fetch_dialogs_usecase.dart' as _i24;
import '../domain/usecase/connect_status_listener/listen_connect_status_usecase.dart'
    as _i11;
import '../domain/usecase/error/listen_to_error_usecase.dart' as _i17;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i3.DatabaseProvider>(() => _i3.DatabaseProvider());
    gh.lazySingleton<_i4.SharedPreferencesGateway>(
        () => _i4.SharedPreferencesGateway());
    gh.lazySingleton<_i5.GrpcGateway>(() => _i5.GrpcGateway());
    gh.lazySingleton<_i6.ConnectListenerGateway>(
        () => _i6.ConnectListenerGateway(
              gh<_i3.DatabaseProvider>(),
              gh<_i5.GrpcGateway>(),
            ));
    gh.lazySingleton<_i7.ConnectStatusListenerService>(() =>
        _i8.ConnectStatusListenerServiceImpl(gh<_i6.ConnectListenerGateway>()));
    gh.lazySingleton<_i9.ErrorService>(
        () => _i10.ErrorServiceImpl(gh<_i6.ConnectListenerGateway>()));
    gh.lazySingleton<_i11.ListenConnectStatusUseCase>(() =>
        _i11.ListenConnectStatusImplUseCase(
            gh<_i7.ConnectStatusListenerService>()));
    gh.lazySingleton<_i12.AuthService>(() => _i13.AuthServiceImpl(
          gh<_i3.DatabaseProvider>(),
          gh<_i5.GrpcGateway>(),
          gh<_i4.SharedPreferencesGateway>(),
        ));
    gh.lazySingleton<_i14.ChatService>(() => _i15.ChatServiceImpl(
          gh<_i3.DatabaseProvider>(),
          gh<_i6.ConnectListenerGateway>(),
          gh<_i4.SharedPreferencesGateway>(),
        ));
    gh.lazySingleton<_i16.ChannelStatusListener>(
        () => _i16.ChannelStatusListener(gh<_i5.GrpcGateway>()));
    gh.lazySingleton<_i17.ListenToErrorUseCase>(
        () => _i17.ListenToErrorImplUseCase(gh<_i9.ErrorService>()));
    gh.lazySingleton<_i18.ChatListService>(() => _i19.ChatListServiceImpl(
          gh<_i6.ConnectListenerGateway>(),
          gh<_i4.SharedPreferencesGateway>(),
        ));
    gh.lazySingleton<_i20.ListenToMessagesUsecase>(
        () => _i20.ListenToMessagesImplUseCase(gh<_i14.ChatService>()));
    gh.lazySingleton<_i21.SendDialogMessageUseCase>(
        () => _i21.SendDialogMessageImplUseCase(gh<_i14.ChatService>()));
    gh.lazySingleton<_i22.FetchMessagesUseCase>(
        () => _i22.FetchMessagesImplUseCase(gh<_i14.ChatService>()));
    gh.lazySingleton<_i23.LoginUseCase>(
        () => _i23.LoginImplUseCase(gh<_i12.AuthService>()));
    gh.lazySingleton<_i24.FetchDialogsUseCase>(
        () => _i24.FetchDialogsImplUseCase(gh<_i18.ChatListService>()));
    gh.lazySingleton<_i25.LogoutUseCase>(
        () => _i25.LogoutImplUseCase(gh<_i12.AuthService>()));
    gh.lazySingleton<_i26.FetchMessageUpdatesUseCase>(
        () => _i26.FetchMessageUpdatesImplUseCase(gh<_i14.ChatService>()));
    gh.lazySingleton<_i27.RegisterDeviceUseCase>(
        () => _i27.RegisterDeviceImplUseCase(gh<_i12.AuthService>()));
    return this;
  }
}
