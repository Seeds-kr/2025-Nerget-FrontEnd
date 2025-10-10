import 'package:flutter/foundation.dart';

class Env {
  /// mock 서버 사용 여부
  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  /// API Base URL
  static String apiBaseUrl() {
    const fromDefine = String.fromEnvironment('BASE_URL', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;

    // 기본값: 로컬
    if (kIsWeb) {
      return 'http://localhost:8080';
    } else {
      return 'http://10.0.2.2:8080';
    }
  }

  /// Google OAuth Client IDs (필요 시 주입)
  // Provide platform-specific client IDs via `--dart-define`.
  // Example: --dart-define=GSI_CLIENT_ID_WEB=<your-web-client-id>
  static const String googleClientIdWeb = String.fromEnvironment(
    'GSI_CLIENT_ID_WEB',
    defaultValue: '',
  );
  static const String googleClientIdAndroid = String.fromEnvironment(
    'GSI_CLIENT_ID_ANDROID',
    defaultValue: '',
  );
  static const String googleClientIdIos = String.fromEnvironment(
    'GSI_CLIENT_ID_IOS',
    defaultValue: '',
  );
}
