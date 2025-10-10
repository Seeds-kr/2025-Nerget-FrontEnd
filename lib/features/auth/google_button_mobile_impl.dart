import 'package:flutter/material.dart';
import 'package:omakase_app/shared/repository/auth_repository.dart';

/// 모바일/데스크톱용 구현체
class GoogleSignInButtonImpl extends StatelessWidget {
  final AuthRepository authRepository;
  final bool isLoading;
  final VoidCallback? onPressed;

  const GoogleSignInButtonImpl({
    super.key,
    required this.authRepository,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 48,
      child: Builder(
        builder: (context) {
          return FilledButton(
            onPressed: isLoading
                ? null
                : (onPressed ??
                      () async {
                        final acc = await authRepository.signInWithGoogle();
                        if (acc == null) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '이 플랫폼에서는 Google 로그인 기능이 지원되지 않습니다. 모바일에서 실행해 주세요.',
                              ),
                            ),
                          );
                        }
                      }),
            child: const Text('Sign in with Google'),
          );
        },
      ),
    );
  }
}
