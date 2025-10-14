import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  const GoogleSignInButton({super.key, required this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
        : const Text('Continue with Google');

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF111111),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFEAEAEA)),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
        child: kIsWeb
            ? Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // 웹에서도 아이콘은 그냥 머터리얼 아이콘으로
            Icon(Icons.g_mobiledata_rounded, size: 24),
            SizedBox(width: 6),
            Text('Continue with Google'),
          ],
        )
            : child,
      ),
    );
  }
}
