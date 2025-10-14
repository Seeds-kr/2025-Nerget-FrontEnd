import 'package:flutter/material.dart';
import 'package:omakase_app/features/home/post_detail_page.dart';
import 'package:omakase_app/features/models/post.dart';
import 'package:omakase_app/features/onboarding/mbti_result_screen.dart';

// Screens
import 'package:omakase_app/features/auth/login_screen.dart';
import 'package:omakase_app/features/onboarding/onboarding_upload_screen.dart';
import 'package:omakase_app/features/home/home_shell.dart';
import 'package:omakase_app/features/onboarding/swipe_test_screen.dart';
import 'package:omakase_app/features/upload/upload_style_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const swipeTest = '/swipeTest';
  static const post = '/post';
  static const mbtiResult = '/mbtiResult';

  // Top-level tabs
  static const feed = '/feed';
  static const community = '/community';
  static const upload = '/upload';
  static const saved = '/saved';
  static const mypage = '/mypage';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        switch (settings.name) {
          case AppRoutes.login:
            return const LoginScreen();
          case AppRoutes.onboarding:
            return const OnboardingUploadScreen();
          case AppRoutes.swipeTest:
            return const SwipeTestScreen();
          case AppRoutes.feed:
            return const HomeShell(initialIndex: 0);
          case AppRoutes.community:
            return const HomeShell(initialIndex: 1);
          case AppRoutes.saved:
            return const HomeShell(initialIndex: 2);
          case AppRoutes.mypage:
            return const HomeShell(initialIndex: 3);
          case AppRoutes.upload:
            return const UploadStyleScreen();
          case AppRoutes.post:
            final post = settings.arguments as Post;
            return PostDetailPage(post: post);
          case AppRoutes.mbtiResult:
            final mbti = settings.arguments as String;
            return MbtiResultScreen(mbti: mbti);

          default:
            return const LoginScreen();
        }
      },
    );
  }
}
