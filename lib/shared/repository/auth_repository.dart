import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

typedef IdTokenHandler = Future<void> Function(String idToken);

/// 플랫폼별 구현이 호출하는 공용 인터페이스
class AuthRepository {
    /// 로그인 성공 시 플랫폼 구현이 채워줄 콜백 (idToken 전달)
    late IdTokenHandler onIdToken;

    /// 플랫폼별 sign-in 위임
    Future<Object?> signInWithGoogle() {
        if (kIsWeb) {
            return AuthRepositoryWeb(onIdToken).signInWithGoogle();
        } else {
            return AuthRepositoryMobile(onIdToken).signInWithGoogle();
        }
    }
}

/// 모바일 구현
class AuthRepositoryMobile extends _AuthBase {
    AuthRepositoryMobile(super.onIdToken);

    @override
    Future<Object?> signInWithGoogle() async {
        final google = await _AuthBase._googleSignIn.signIn();
        if (google == null) return null;

        final auth = await google.authentication;
        final idToken = auth.idToken;
        if (idToken == null) return null;

        await onIdToken(idToken);
        return google;
    }
}

/// 웹 구현
class AuthRepositoryWeb extends _AuthBase {
    AuthRepositoryWeb(super.onIdToken);

    @override
    Future<Object?> signInWithGoogle() async {
        final google = await (_AuthBase._googleSignIn.signInSilently()
            ?? _AuthBase._googleSignIn.signIn());
        if (google == null) return null;

        final auth = await google.authentication;
        final idToken = auth.idToken;
        if (idToken == null) return null;

        await onIdToken(idToken);
        return google;
    }
}

/// 공통 베이스
abstract class _AuthBase {
    _AuthBase(this.onIdToken);
    final IdTokenHandler onIdToken;

    // google_sign_in 공용 인스턴스
    static final _googleSignIn = GoogleSignIn(
        scopes: <String>[
            'email',
            'openid',
            // 'profile', // 필요 시
        ],
    );

    Future<Object?> signInWithGoogle();
}
