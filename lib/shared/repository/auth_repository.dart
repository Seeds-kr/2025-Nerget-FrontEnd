// 이 파일만 import 하세요. (플랫폼별 구현 자동 선택)
export 'auth_repository_mobile.dart'
    if (dart.library.html) 'auth_repository_web.dart';
