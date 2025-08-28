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
      child: FilledButton(
        onPressed:
            isLoading
                ? null
                : (onPressed ??
                    () async {
                      await authRepository.signInWithGoogle();
                    }),
        child: const Text('Sign in with Google'),
      ),
    );
  }
}
