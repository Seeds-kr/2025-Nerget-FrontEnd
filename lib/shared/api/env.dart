import 'package:flutter/foundation.dart';

class Env {
  static String apiBaseUrl() {
    if (kIsWeb) return 'http://localhost:8080'; // 로컬 웹
    return 'http://10.0.2.2:8080'; // Android 에뮬레이터
  }
}
