import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService(this._preferences);

  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';
  static const String userIdKey = 'userId';
  static const String languageKey = 'language';
  static const String themeModeKey = 'themeMode';
  static const String firstLaunchKey = 'firstLaunch';
  static const String deviceIdKey = 'deviceId';
  static const String accessTokenExpiresAtKey = 'accessTokenExpiresAt';
  static const String refreshTokenExpiresAtKey = 'refreshTokenExpiresAt';
  static const String fcmRegisteredToken = 'fcmRegisteredToken';

  final SharedPreferences _preferences;

  static Future<LocalStorageService> create() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalStorageService(preferences);
  }

  Future<void> setFCMRegisteredToken(String token) async {
    await _preferences.setString(fcmRegisteredToken, token);
  }

  String? getFCMRegisteredToken() {
    return _preferences.getString(fcmRegisteredToken);
  }
  Future <bool> removeFCMRegisteredToken() {
    return _preferences.remove(fcmRegisteredToken);
  }



  Future<void> saveAccessTokenExpiresAt(DateTime value) async {
    await _preferences.setString(
      accessTokenExpiresAtKey,
      value.toUtc().toIso8601String(),
    );
  }

  DateTime? getAccessTokenExpiresAt() {
    final value = _preferences.getString(accessTokenExpiresAtKey);

    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value)?.toUtc();
  }
  Future<void> saveRefereshTokenExpiresAt(DateTime? value) async {
    if (value == null) {
      await _preferences.remove(refreshTokenExpiresAtKey);
      return;
    }
    await _preferences.setString(
      refreshTokenExpiresAtKey,
      value.toUtc().toIso8601String(),
    );
  }

  DateTime? getrefreashTokenExpiresAt() {
    final value = _preferences.getString(refreshTokenExpiresAtKey);

    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value)?.toUtc();
  }

  Future<void> saveToken(String token) async {
    print(
      '[AUTH DEBUG] save access token: ${token.isNotEmpty} (instance: ${identityHashCode(this)})',
    );
    await _preferences.setString(accessTokenKey, token);
  }

  String? getToken() {
    final token = _preferences.getString(accessTokenKey);
    print(
      '[AUTH DEBUG] get access token: ${token != null && token.isNotEmpty} (instance: ${identityHashCode(this)})',
    );
    return token;
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    print(
      '[AUTH DEBUG] save refresh token: ${refreshToken.isNotEmpty} (instance: ${identityHashCode(this)})',
    );
    await _preferences.setString(refreshTokenKey, refreshToken);
  }

  String? getRefreshToken() {
    final refreshToken = _preferences.getString(refreshTokenKey);
    print(
      '[AUTH DEBUG] get refresh token: ${refreshToken != null && refreshToken.isNotEmpty} (instance: ${identityHashCode(this)})',
    );
    return refreshToken;
  }

  Future<void> saveUserId(String userId) async {
    await _preferences.setString(userIdKey, userId);
  }

  String? getUserId() => _preferences.getString(userIdKey);

  Future<void> saveLanguage(String languageCode) async {
    await _preferences.setString(languageKey, languageCode);
  }

  String? getLanguage() => _preferences.getString(languageKey);

  Future<void> saveThemeMode(String themeMode) async {
    await _preferences.setString(themeModeKey, themeMode);
  }

  String? getThemeMode() => _preferences.getString(themeModeKey);

  Future<void> saveDeviceId(String deviceId) async {
    await _preferences.setString(deviceIdKey, deviceId);
  }

  String? getDeviceId() => _preferences.getString(deviceIdKey);

  Future<void> removeDeviceId() async {
    await _preferences.remove(deviceIdKey);
  }

  Future<void> clearAll() async {
    print(
      '[AUTH DEBUG] clearAll executed (instance: ${identityHashCode(this)})',
    );
    await _preferences.remove(accessTokenKey);
    await _preferences.remove(refreshTokenKey);
    await _preferences.remove(userIdKey);
    await _preferences.remove(languageKey);
    await _preferences.remove(themeModeKey);
    await _preferences.remove(firstLaunchKey);
    await _preferences.remove(deviceIdKey);
    await _preferences.remove(accessTokenExpiresAtKey);
    await _preferences.remove(refreshTokenExpiresAtKey);
  }

  Future<void> clearSession() async {
    print(
      '[AUTH DEBUG] clearSession executed (instance: ${identityHashCode(this)})',
    );
    await _preferences.remove(accessTokenKey);
    await _preferences.remove(refreshTokenKey);
    await _preferences.remove(userIdKey);
    await _preferences.remove(deviceIdKey);
    await _preferences.remove(accessTokenExpiresAtKey);
    await _preferences.remove(refreshTokenExpiresAtKey);
  }

  Future<void> setFirstLaunchDone() async {
    await _preferences.setBool(firstLaunchKey, false);
  }

  bool isFirstLaunch() {
    return _preferences.getBool(firstLaunchKey) ?? true;
  }
}