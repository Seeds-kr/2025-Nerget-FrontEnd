import 'package:flutter/material.dart';
import 'package:omakase_app/shared/repository/auth_repository.dart';

// 플랫폼별 구현을 같은 이름으로 불러오기
import 'google_button_mobile_impl.dart'
    if (dart.library.html) 'google_button_web_impl.dart'
    as impl;

/// 화면에서 쓰는 공용 버튼 위젯
class GoogleSignInButton extends StatelessWidget {
  final AuthRepository authRepository;
  final bool isLoading;
  final VoidCallback? onPressed; // 모바일에서만 사용(웹은 무시)

  const GoogleSignInButton({
    super.key,
    required this.authRepository,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return impl.GoogleSignInButtonImpl(
      authRepository: authRepository,
      isLoading: isLoading,
      onPressed: onPressed,
    );
  }
}
