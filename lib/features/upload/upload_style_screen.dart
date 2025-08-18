import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:omakase_app/router/app_router.dart';
import 'package:omakase_app/shared/api/prefs.dart';

class UploadStyleScreen extends StatelessWidget {
  const UploadStyleScreen({super.key});

  Future<void> _complete(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKeys.profileCompleted, true);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('스타일 업로드')),
      body: Center(
        child: FilledButton(
          onPressed: () => _complete(context),
          child: const Text('완료하고 홈으로'),
        ),
      ),
    );
  }
}
