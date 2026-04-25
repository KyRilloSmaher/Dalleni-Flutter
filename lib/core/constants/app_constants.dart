class AppConstants {
  const AppConstants._();

  static const String appTitle = 'Dalleni';
  static const String baseUrl = String.fromEnvironment(
    'DALLENI_BASE_URL',
    defaultValue: 'https://dalleni.tryasp.net/api',
  );
}
