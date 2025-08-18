import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../router/app_router.dart';

class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!context.mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(child: Text('피드/추천 들어갈 자리')),
    );
  }
}
