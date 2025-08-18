import 'package:flutter/material.dart';
import 'screens/main_tabs.dart';
import 'state/app_state.dart';

void main() {
  final appState = AppState()..seedDummy(); // 더미 데이터 주입
  runApp(AppStateScope(
    notifier: appState,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nerget Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const MainTabs(),
    );
  }
}


