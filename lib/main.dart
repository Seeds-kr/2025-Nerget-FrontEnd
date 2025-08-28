import 'package:flutter/material.dart';
import 'router/app_router.dart';
import './features/state/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OmakaseApp());
}

class OmakaseApp extends StatelessWidget {
  const OmakaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '옷마카세',
      initialRoute: AppRoutes.login,
      routes: AppRouter.routes, // ✅ Navigator 라우팅 사용
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
    );
  }
}
