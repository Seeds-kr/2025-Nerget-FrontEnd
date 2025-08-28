import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  AuthRepository();

  /// 웹/모바일 공통 토큰 콜백 (모바일에서도 맞춰 제공)
  void Function(String idToken)? onIdToken;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );

  /// login_screen.dart가 기대하는 시그니처 유지
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      // 모바일도 흐름 통일: 토큰 있으면 콜백 호출
      final auth = await account?.authentication;
      final token = auth?.idToken;
      if (token != null) {
        final cb = onIdToken;
        if (cb != null) cb(token);
      }
      return account; // null == 사용자 취소
    } catch (_) {
      return null;
    }
  }

  void renderGoogleButton(String containerId) {
    // 모바일/데스크톱에서는 의미 없음
  }

  Future<void> signOut() => _googleSignIn.signOut();
}
