import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:webitel_sdk/domain/usecase/fetch_device_id_usecase.dart';

part 'device_info_event.dart';
part 'device_info_state.dart';

class DeviceInfoBloc extends Bloc<DeviceInfoEvent, DeviceInfoState> {
  DeviceInfoBloc(this._fetchDeviceIdUseCase)
      : super(DeviceInfoState.initial()) {
    on<FetchDeviceIdEvent>((event, emit) async {
      final deviceId = await _fetchDeviceIdUseCase();
      emit(state.copyWith(deviceId: deviceId));
    });
  }

  final FetchDeviceIdUseCase _fetchDeviceIdUseCase;
}
