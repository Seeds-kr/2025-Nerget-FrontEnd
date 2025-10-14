import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:omakase_app/router/app_router.dart';
import 'package:omakase_app/shared/repository/auth_repository.dart';
import 'package:omakase_app/shared/api/auth_api.dart';
import 'package:omakase_app/features/auth/google_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authRepository = AuthRepository();
  final _authApi = AuthApi();
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    // ✅ 플랫폼별 Google 로그인 완료 후 서버 로그인 로직
    _authRepository.onIdToken = (String idToken) async {
      if (!mounted) return;
      setState(() => _loading = true);
      try {
        final res = await _authApi.loginWithGoogle(idToken);
        if (!res.ok) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('서버 로그인 실패')));
          return;
        }

        // 신규 유저 → 온보딩
        if (res.isNewUser) {
          if (!mounted) return;
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.onboarding, (route) => false);
          return;
        }

        // 기존 유저 → 프로필 여부 확인 후 분기
        try {
          final me = await _authApi.me(token: res.token);
          final completed = (me['profileCompleted'] == true);
          if (!mounted) return;
          if (completed) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(AppRoutes.feed, (route) => false);
          } else {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(AppRoutes.onboarding, (route) => false);
          }
        } catch (_) {
          if (!mounted) return;
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.onboarding, (route) => false);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('오류: $e')));
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    };

    // ✅ 웹 환경에서는 원탭(FedCM) 로그인 자동 시도
    if (kIsWeb) {
      // ignore: discarded_futures
      _authRepository.signInWithGoogle();
    }
  }

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF111111);
    const gray = Color(0xFF7A7A7A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: !kIsWeb,
        bottom: !kIsWeb,
        child: Stack(
          children: [
            Center(
              child: LayoutBuilder(
                builder: (context, c) {
                  final maxW =
                  c.maxWidth >= 500 ? 320.0 : c.maxWidth * 0.86; // 가로폭 고정
                  return ConstrainedBox(
                    constraints: BoxConstraints.tightFor(width: maxW),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '옷마카세',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: black,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 로고 이미지
                        AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              color: Colors.black,
                              child: Image.asset(
                                'assets/omakase.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.image_not_supported,
                                      color: Colors.white70, size: 48),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ✅ 구글 로그인 버튼
                        GoogleSignInButton(
                          isLoading: _loading,
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRoutes.onboarding, (route) => false);
                          },
                        ),
                        const SizedBox(height: 12),

                        // 태그라인
                        const Text(
                          'Find your own style, share with community',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: black,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 로딩 오버레이
            if (_loading)
              Container(
                color: const Color.fromRGBO(0, 0, 0, 0.06),
                alignment: Alignment.center,
                child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(strokeWidth: 3)),
              ),

            // 푸터
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: IgnorePointer(
                child: Text(
                  '© 2025 Otmakase',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: gray, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
