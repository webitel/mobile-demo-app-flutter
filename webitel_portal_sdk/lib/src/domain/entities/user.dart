class UserEntity {
  final String id;
  final String name;
  final String baseUrl;
  final String clientToken;
  final String deviceId;
  final String accessToken;
  final String appName;
  final String appVersion;
  final String packageName;
  final String packageVersion;
  final String userAgent;

  UserEntity({
    required this.accessToken,
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.clientToken,
    required this.deviceId,
    required this.appName,
    required this.appVersion,
    required this.packageName,
    required this.packageVersion,
    required this.userAgent,
  });

  factory UserEntity.initial() {
    return UserEntity(
      accessToken: '',
      id: '',
      name: '',
      baseUrl: '',
      clientToken: '',
      deviceId: '',
      appName: '',
      appVersion: '',
      packageName: '',
      packageVersion: '',
      userAgent: '',
    );
  }

  // Method to convert UserEntity to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accessToken': accessToken,
      'name': name,
      'baseUrl': baseUrl,
      'clientToken': clientToken,
      'deviceId': deviceId,
      'appName': appName,
      'appVersion': appVersion,
      'packageName': packageName,
      'packageVersion': packageVersion,
      'userAgent': userAgent,
    };
  }

  // Method to create UserEntity from a Map
  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'],
      accessToken: map['accessToken'],
      name: map['name'],
      baseUrl: map['baseUrl'],
      clientToken: map['clientToken'],
      deviceId: map['deviceId'],
      appName: map['appName'],
      appVersion: map['appVersion'],
      packageName: map['packageName'],
      packageVersion: map['packageVersion'],
      userAgent: map['userAgent'],
    );
  }
}
