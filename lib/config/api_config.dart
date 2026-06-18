/// Configuration centrale du backend Django.
///
/// Surchargez via --dart-define :
///   flutter run --dart-define=API_HOST=192.168.1.42 --dart-define=API_PORT=8000
class ApiConfig {
  static const String host = String.fromEnvironment(
    'API_HOST',
    defaultValue: '10.0.2.2', // 10.0.2.2 = loopback hôte depuis émulateur Android
  );
  static const String port = String.fromEnvironment(
    'API_PORT',
    defaultValue: '8000',
  );
  static const String scheme = String.fromEnvironment(
    'API_SCHEME',
    defaultValue: 'http',
  );

  static String get httpBase => '$scheme://$host:$port';
  static String get wsBase => '${scheme == 'https' ? 'wss' : 'ws'}://$host:$port';

  static String get apiBase => '$httpBase/api';
}
