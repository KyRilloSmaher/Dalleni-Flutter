class DeviceRegistrationRequestModel {
  const DeviceRegistrationRequestModel({
    required this.deviceToken,
    this.platform = 1,
  });

  final String deviceToken;
  final int platform;

  Map<String, dynamic> toJson() {
    return {
      'deviceToken': deviceToken,
      'platform': platform,
    };
  }
}
