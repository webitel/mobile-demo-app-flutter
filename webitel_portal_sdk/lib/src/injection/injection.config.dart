// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../data/gateway/channel_status_listener.dart' as _i20;
import '../data/gateway/connect_listener_gateway.dart' as _i7;
import '../data/gateway/grpc_gateway.dart' as _i5;
import '../data/gateway/image_compress_gateway.dart' as _i6;
import '../data/gateway/shared_preferences_gateway.dart' as _i4;
import '../data/service_impl/auth_service_impl.dart' as _i18;
import '../data/service_impl/chat_list_service_impl.dart' as _i27;
import '../data/service_impl/chat_service_impl.dart' as _i22;
import '../data/service_impl/connect_status_listener_service_impl.dart' as _i13;
import '../data/service_impl/error_service_impl.dart' as _i15;
import '../data/service_impl/media_service_impl.dart' as _i11;
import '../data/service_impl/portal_service_impl.dart' as _i9;
import '../database/database.dart' as _i3;
import '../domain/services/auth_service.dart' as _i17;
import '../domain/services/chat_list_service.dart' as _i26;
import '../domain/services/chat_service.dart' as _i21;
import '../domain/services/connect_status_listener_service.dart' as _i12;
import '../domain/services/error_service.dart' as _i14;
import '../domain/services/media_service.dart' as _i10;
import '../domain/services/portal_service.dart' as _i8;
import '../domain/usecase/auth/login_usecase.dart' as _i30;
import '../domain/usecase/auth/logout_usecase.dart' as _i33;
import '../domain/usecase/auth/register_device_usecase.dart' as _i37;
import '../domain/usecase/chat/enter_chat_usecase.dart' as _i31;
import '../domain/usecase/chat/exit_chat_usecase.dart' as _i34;
import '../domain/usecase/chat/fetch_message_updates.dart' as _i35;
import '../domain/usecase/chat/fetch_messages.dart' as _i36;
import '../domain/usecase/chat/listen_to_messages_usecase.dart' as _i29;
import '../domain/usecase/chat/send_message_usecase.dart' as _i28;
import '../domain/usecase/chat_list/fetch_dialogs_usecase.dart' as _i32;
import '../domain/usecase/connect_status_listener/listen_connect_status_usecase.dart'
    as _i16;
import '../domain/usecase/error/listen_to_error_usecase.dart' as _i25;
import '../domain/usecase/media/fetch_media_usecase.dart' as _i23;
import '../domain/usecase/media/upload_file_usecase.dart' as _i24;
import '../domain/usecase/portal/exit_portal.dart' as _i19;

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
    gh.lazySingleton<_i6.ImageCompressGateway>(
        () => _i6.ImageCompressGateway());
    gh.lazySingleton<_i7.ConnectListenerGateway>(
        () => _i7.ConnectListenerGateway(
              gh<_i3.DatabaseProvider>(),
              gh<_i5.GrpcGateway>(),
            ));
    gh.lazySingleton<_i8.PortalService>(
        () => _i9.PortalServiceImpl(gh<_i7.ConnectListenerGateway>()));
    gh.lazySingleton<_i10.MediaService>(() => _i11.MediaServiceImpl(
          gh<_i5.GrpcGateway>(),
          gh<_i6.ImageCompressGateway>(),
        ));
    gh.lazySingleton<_i12.ConnectStatusListenerService>(() =>
        _i13.ConnectStatusListenerServiceImpl(
            gh<_i7.ConnectListenerGateway>()));
    gh.lazySingleton<_i14.ErrorService>(
        () => _i15.ErrorServiceImpl(gh<_i7.ConnectListenerGateway>()));
    gh.lazySingleton<_i16.ListenConnectStatusUseCase>(() =>
        _i16.ListenConnectStatusImplUseCase(
            gh<_i12.ConnectStatusListenerService>()));
    gh.lazySingleton<_i17.AuthService>(() => _i18.AuthServiceImpl(
          gh<_i3.DatabaseProvider>(),
          gh<_i5.GrpcGateway>(),
          gh<_i4.SharedPreferencesGateway>(),
        ));
    gh.lazySingleton<_i19.ExitPortalUseCase>(
        () => _i19.ExitPortalImplUseCase(gh<_i8.PortalService>()));
    gh.lazySingleton<_i20.ChannelStatusListener>(
        () => _i20.ChannelStatusListener(gh<_i5.GrpcGateway>()));
    gh.lazySingleton<_i21.ChatService>(() => _i22.ChatServiceImpl(
          gh<_i3.DatabaseProvider>(),
          gh<_i7.ConnectListenerGateway>(),
          gh<_i4.SharedPreferencesGateway>(),
        ));
    gh.lazySingleton<_i23.FetchMediaUseCase>(
        () => _i23.FetchMediaImplUseCase(gh<_i10.MediaService>()));
    gh.lazySingleton<_i24.UploadMediaUseCase>(
        () => _i24.UploadMediaImplUseCase(gh<_i10.MediaService>()));
    gh.lazySingleton<_i25.ListenToErrorUseCase>(
        () => _i25.ListenToErrorImplUseCase(gh<_i14.ErrorService>()));
    gh.lazySingleton<_i26.ChatListService>(() => _i27.ChatListServiceImpl(
          gh<_i7.ConnectListenerGateway>(),
          gh<_i4.SharedPreferencesGateway>(),
        ));
    gh.lazySingleton<_i28.SendMessageUseCase>(
        () => _i28.SendMessageImplUseCase(gh<_i21.ChatService>()));
    gh.lazySingleton<_i29.ListenToMessagesUsecase>(
        () => _i29.ListenToMessagesImplUseCase(gh<_i21.ChatService>()));
    gh.lazySingleton<_i30.LoginUseCase>(
        () => _i30.LoginImplUseCase(gh<_i17.AuthService>()));
    gh.lazySingleton<_i31.EnterChatUsecase>(
        () => _i31.EnterChatImplUseCase(gh<_i21.ChatService>()));
    gh.lazySingleton<_i32.FetchDialogsUseCase>(
        () => _i32.FetchDialogsImplUseCase(gh<_i26.ChatListService>()));
    gh.lazySingleton<_i33.LogoutUseCase>(
        () => _i33.LogoutImplUseCase(gh<_i17.AuthService>()));
    gh.lazySingleton<_i34.ExitChatUsecase>(
        () => _i34.ExitChatImplUseCase(gh<_i21.ChatService>()));
    gh.lazySingleton<_i35.FetchUpdatesUseCase>(
        () => _i35.FetchUpdatesImplUseCase(gh<_i21.ChatService>()));
    gh.lazySingleton<_i36.FetchMessagesUseCase>(
        () => _i36.FetchMessagesImplUseCase(gh<_i21.ChatService>()));
    gh.lazySingleton<_i37.RegisterDeviceUseCase>(
        () => _i37.RegisterDeviceImplUseCase(gh<_i17.AuthService>()));
    return this;
  }
}
