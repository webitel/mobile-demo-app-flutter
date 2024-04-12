part of 'device_info_bloc.dart';

class DeviceInfoState extends Equatable {
  final String deviceId;

  const DeviceInfoState({required this.deviceId});

  static DeviceInfoState initial() {
    return const DeviceInfoState(deviceId: '');
  }

  @override
  List<Object?> get props => [deviceId];

  DeviceInfoState copyWith({
    String? deviceId,
  }) {
    return DeviceInfoState(
      deviceId: deviceId ?? this.deviceId,
    );
  }
}
