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
  final AuthRepository _authRepository = AuthRepository();
  final AuthApi _authApi = AuthApi();
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _authRepository.onIdToken = (String idToken) async {
      if (!mounted) return;
      setState(() => _loading = true);
      try {
        final res = await _authApi.loginWithGoogle(idToken);
        if (!res.ok) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('서버 로그인 실패')));
          setState(() => _loading = false);
          return;
        }

        // 신규 유저 → 온보딩 업로드 화면으로 이동
        if (res.isNewUser) {
          if (!mounted) return;
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.onboarding, (route) => false);
          return;
        }

        // 기존 유저 → me 확인 (실패해도 홈으로)
        try {
          final me = await _authApi.me(token: res.token);
          final completed = (me['profileCompleted'] == true);
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.onboarding,
            (route) => false,
          );
          return;
        } catch (_) {
          if (!mounted) return;
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.onboarding, (route) => false);
          return;
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류: $e')));
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    };

    // 초기 시도 (웹은 원탭/FedCM 유도, 모바일은 계정 선택)
    // ignore: discarded_futures
    _authRepository.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // 웹은 상/하 여백을 꺼서 진짜 중앙 배치
        top: !kIsWeb,
        bottom: !kIsWeb,
        left: true,
        right: true,
        child: Stack(
          children: [
            Center(
              child: LayoutBuilder(
                builder: (context, c) {
                  // 🔑 모든 요소가 공유하는 “단일 폭”
                  final double maxW = c.maxWidth >= 500
                      ? 320.0
                      : c.maxWidth * 0.86;

                  return ConstrainedBox(
                    constraints: BoxConstraints.tightFor(width: maxW),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          '옷마카세',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 로고(정사각형) — maxW에 맞춰 중심 정렬
                        AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              color: Colors.black,
                              child: Image.asset(
                                'assets/omakase.png', // pubspec.yaml에 등록 필요
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white70,
                                    size: 48,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ✅ [수정된 부분] 불필요한 래퍼 위젯(SizedBox, Align)을 제거하여
                        // Column의 'crossAxisAlignment'가 버튼을 직접 중앙 정렬하도록 수정했습니다.
                        // 이렇게 하면 정렬 문제와 잠재적인 오버플로우 버그가 모두 해결됩니다.
                        GoogleSignInButton(
                          authRepository: _authRepository,
                          isLoading: _loading,
                          onPressed: () async {
                            if (kIsWeb) return; // 웹은 내부에서 GSI 렌더
                            setState(() => _loading = true);
                            try {
                              await _authRepository.signInWithGoogle();
                            } finally {
                              if (mounted) {
                                setState(() => _loading = false);
                              }
                            }
                          },
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 로딩 오버레이
            if (_loading)
              Container(
                color: Colors.black.withOpacity(0.06),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
