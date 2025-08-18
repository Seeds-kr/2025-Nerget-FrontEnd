import 'package:flutter/material.dart';
import '../../router/app_router.dart';

class SwipeTestScreen extends StatefulWidget {
  const SwipeTestScreen({super.key});

  @override
  State<SwipeTestScreen> createState() => _SwipeTestScreenState();
}

class _SwipeTestScreenState extends State<SwipeTestScreen> {
  int _i = 0;

  void _onSwipe() {
    setState(() => _i++);
    if (_i >= 5) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.upload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('스타일 스와이프')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('남은 카드: ${5 - _i}'),
            const SizedBox(height: 12),
            FilledButton(onPressed: _onSwipe, child: const Text('다음(스와이프 대체)')),
          ],
        ),
      ),
    );
  }
}
