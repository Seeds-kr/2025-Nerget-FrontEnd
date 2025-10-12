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
    // 개발/테스트 편의를 위해 기본값을 설정합니다.
    defaultValue:
        '1076507336995-uo4b83nsjjc24rcot71546lntebifp5k.apps.googleusercontent.com',
  );
  static const String googleClientIdAndroid = String.fromEnvironment(
    'GSI_CLIENT_ID_ANDROID',
    // 개발/테스트 편의를 위해 기본값을 설정합니다.
    defaultValue:
        '1076507336995-qchshuqdi1882e7ne9jsvna09c03oo64.apps.googleusercontent.com',
  );
  static const String googleClientIdIos = String.fromEnvironment(
    'GSI_CLIENT_ID_IOS',
    // 기본값으로 iOS 클라이언트 ID를 넣음(개발/테스트 편의).
    // 프로덕션에서는 --dart-define로 주입하거나 보안정책에 따라 관리하세요.
    defaultValue:
        '1076507336995-pds8nuet9g2tjm07f891spgqrhn45p3c.apps.googleusercontent.com',
  );
}
