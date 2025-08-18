import 'package:flutter/material.dart';
import 'package:omakase_app/features/auth/login_screen.dart';
import 'package:omakase_app/features/home/home_shell.dart';
import 'package:omakase_app/features/onboarding/swipe_test_screen.dart';
import 'package:omakase_app/features/upload/upload_style_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String swipe = '/swipe';
  static const String upload = '/upload';
  static const String home = '/home';
}

class AppRouter {
  static final Map<String, WidgetBuilder> routes = {
    AppRoutes.login: (_) => LoginScreen(), // const 없어도 됩니다
    AppRoutes.swipe: (_) => const SwipeTestScreen(),
    AppRoutes.upload: (_) => const UploadStyleScreen(),
    AppRoutes.home: (_) => const HomeShell(),
  };
}
