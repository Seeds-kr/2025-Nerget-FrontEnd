import 'package:flutter/material.dart';

// Screens
import 'package:omakase_app/features/auth/login_screen.dart';
import 'package:omakase_app/features/onboarding/onboarding_upload_screen.dart';
import 'package:omakase_app/features/home/home_shell.dart';
import 'package:omakase_app/features/onboarding/swipe_test_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const SwipeTestScreen = '/swipeTest';
  // Top-level tabs
  static const feed = '/feed';
  static const community = '/community';
  static const upload = '/upload';
  static const saved = '/saved';
  static const mypage = '/mypage';
  static const Swipe = '/swipe';
  static const Upload = '/upload-onboarding';
}

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
    AppRoutes.login: (_) => const LoginScreen(),
    AppRoutes.onboarding: (_) => const OnboardingUploadScreen(),
    AppRoutes.SwipeTestScreen: (_) => const SwipeTestScreen(),
    AppRoutes.feed: (_) => const HomeShell(initialIndex: 0),
    AppRoutes.community: (_) => const HomeShell(initialIndex: 1),
    AppRoutes.upload: (_) => const HomeShell(initialIndex: 2),
    AppRoutes.saved: (_) => const HomeShell(initialIndex: 3),
    AppRoutes.mypage: (_) => const HomeShell(initialIndex: 4),
    AppRoutes.Upload: (_) => const OnboardingUploadScreen(),
    AppRoutes.Swipe: (_) => const SwipeTestScreen(),
  };
}
