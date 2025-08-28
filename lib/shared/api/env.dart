import 'package:flutter/foundation.dart';

class Env {
  /// mock 서버를 쓸지 여부 (flutter run --dart-define=USE_MOCK=true/false)
  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  /// API Base URL (flutter run --dart-define=BASE_URL=... 로 주입 가능)
  static String apiBaseUrl() {
    const fromDefine = String.fromEnvironment('BASE_URL', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;

    // 기본값: 로컬 환경
    if (kIsWeb) {
      // 웹일 때
      return 'http://localhost:8080';
    } else {
      // 안드로이드 에뮬레이터에서 PC localhost 접근용
      return 'http://10.0.2.2:8080';
    }
  }

  /// Google OAuth Web Client ID (flutter run --dart-define=GOOGLE_CLIENT_ID=... 로 주입)
  static const String googleWebClientId = String.fromEnvironment(
    '1076507336995-uo4b83nsjjc24rcot71546lntebifp5k.apps.googleusercontent.com',
    defaultValue: '',
  );
}
