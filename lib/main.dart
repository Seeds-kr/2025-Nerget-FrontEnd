import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'router/app_router.dart';
import 'package:omakase_app/shared/api/prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OmakaseApp());
}

class OmakaseApp extends StatelessWidget {
  const OmakaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '옷마카세',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        scaffoldBackgroundColor: const Color(0xFFFFF4F4),
        useMaterial3: true,
      ),
      home: const _AuthGate(),
      routes: AppRouter.routes,
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(PrefKeys.loggedIn) ?? false;

    if (!mounted) return;

    if (!loggedIn) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      return;
    }

    final completed = prefs.getBool(PrefKeys.profileCompleted) ?? false;
    Navigator.of(
      context,
    ).pushReplacementNamed(completed ? AppRoutes.home : AppRoutes.swipe);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
