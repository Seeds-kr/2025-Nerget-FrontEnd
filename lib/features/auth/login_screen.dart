import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../router/app_router.dart';
import '../../shared/api/auth_api.dart';
import 'package:omakase_app/shared/api/prefs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  final _google = GoogleSignIn(scopes: ['email', 'profile']);
  final _authApi = AuthApi();

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      // 1) 구글 로그인
      final account = await _google.signIn();
      if (account == null) throw Exception('Sign-in canceled');
      final auth = await account.authentication; // accessToken / idToken
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('No idToken');

      // 2) 백엔드 로그인 호출
      final resp = await _authApi.loginWithGoogle(idToken);

      // 3) 토큰/플래그 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', resp.accessToken);
      await prefs.setBool(PrefKeys.loggedIn, true);

      // 4) 신규/기존 분기
      if (resp.isNewUser) {
        await prefs.setBool(PrefKeys.hasAccount, true);
        await prefs.setString(PrefKeys.onboarding, 'upload');
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.upload);
      } else {
        await prefs.setString(PrefKeys.onboarding, 'done');
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: FilledButton.icon(
          onPressed: _loading ? null : _signIn,
          icon: const Icon(Icons.login),
          label: Text(_loading ? 'Signing in...' : 'Sign in with Google'),
        ),
      ),
    );
  }
}
