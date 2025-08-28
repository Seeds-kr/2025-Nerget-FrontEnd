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

        // 신규 유저 → 온보딩
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
            completed ? AppRoutes.feed : AppRoutes.onboarding,
            (route) => false,
          );
          return;
        } catch (_) {
          if (!mounted) return;
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.feed, (route) => false);
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
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child:
            _loading
                ? const CircularProgressIndicator()
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Login'),
                    const SizedBox(height: 12),
                    GoogleSignInButton(
                      authRepository: _authRepository,
                      isLoading: _loading,
                      onPressed: () async {
                        if (kIsWeb) return; // 웹은 내부에서 GSI 렌더
                        setState(() => _loading = true);
                        try {
                          await _authRepository.signInWithGoogle();
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                    ),
                  ],
                ),
      ),
    );
  }
}
