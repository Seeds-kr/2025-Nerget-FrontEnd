import 'package:flutter/material.dart';

// Screens
import 'package:omakase_app/features/auth/login_screen.dart';
import 'package:omakase_app/features/onboarding/onboarding_upload_screen.dart';
import 'package:omakase_app/features/home/home_shell.dart';
import 'package:omakase_app/features/onboarding/swipe_test_screen.dart';
import 'package:omakase_app/features/upload/upload_style_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const SwipeTestScreen = '/swipeTest';
  static const home = '/home';
  static const Swipe = '/swipe';
  static const Upload = '/upload';
}

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
    AppRoutes.login: (_) => const LoginScreen(),
    AppRoutes.onboarding: (_) => const OnboardingUploadScreen(),
    AppRoutes.SwipeTestScreen: (_) => const SwipeTestScreen(),
    AppRoutes.home: (_) => const HomeShell(),
    AppRoutes.Upload: (_) => const OnboardingUploadScreen(),
    AppRoutes.Swipe: (_) => const SwipeTestScreen(),
  };
}
