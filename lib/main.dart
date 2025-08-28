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
    final appState = AppState()..seedCommunityAssetsIfEmpty();
    return AppStateScope(
      notifier: appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '옷마카세',
        initialRoute: AppRoutes.login,
        routes: AppRouter.routes,
        theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      ),
    );
  }
}
