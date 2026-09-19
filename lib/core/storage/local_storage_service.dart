import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService(this._preferences);

  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';
  static const String userIdKey = 'userId';
  static const String languageKey = 'language';
  static const String themeModeKey = 'themeMode';
  static const String firstLaunchKey = 'firstLaunch';

  final SharedPreferences _preferences;

  static Future<LocalStorageService> create() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalStorageService(preferences);
  }

  Future<void> saveToken(String token) async {
    print('[AUTH DEBUG] save access token: ${token.isNotEmpty} (instance: ${identityHashCode(this)})');
    await _preferences.setString(accessTokenKey, token);
  }

  String? getToken() {
    final token = _preferences.getString(accessTokenKey);
    print('[AUTH DEBUG] get access token: ${token != null && token.isNotEmpty} (instance: ${identityHashCode(this)})');
    return token;
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    print('[AUTH DEBUG] save refresh token: ${refreshToken.isNotEmpty} (instance: ${identityHashCode(this)})');
    await _preferences.setString(refreshTokenKey, refreshToken);
  }

  String? getRefreshToken() {
    final refreshToken = _preferences.getString(refreshTokenKey);
    print('[AUTH DEBUG] get refresh token: ${refreshToken != null && refreshToken.isNotEmpty} (instance: ${identityHashCode(this)})');
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

  Future<void> clearAll() async {
    print('[AUTH DEBUG] clearAll executed (instance: ${identityHashCode(this)})');
    await _preferences.remove(accessTokenKey);
    await _preferences.remove(refreshTokenKey);
    await _preferences.remove(userIdKey);
    await _preferences.remove(languageKey);
    await _preferences.remove(themeModeKey);
    await _preferences.remove(firstLaunchKey);
  }

  Future<void> clearSession() async {
    print('[AUTH DEBUG] clearSession executed (instance: ${identityHashCode(this)})');
    await _preferences.remove(accessTokenKey);
    await _preferences.remove(refreshTokenKey);
    await _preferences.remove(userIdKey);
  }

  Future<void> setFirstLaunchDone() async {
    await _preferences.setBool(firstLaunchKey, false);
  }

  bool isFirstLaunch() {
    return _preferences.getBool(firstLaunchKey) ?? true;
  }
}
