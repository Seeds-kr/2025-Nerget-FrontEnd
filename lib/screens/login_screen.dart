import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고 placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.image, size: 40, color: Colors.grey[500]),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Nuget',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 40),

                // Google
                _SocialLoginButton(
                  text: 'Continue with Google',
                  icon: Image.asset('assets/google.png', height: 20),
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  border: true,
                ),

                const SizedBox(height: 16),

                // Kakao
                _SocialLoginButton(
                  text: 'Continue with Kakao',
                  icon: Image.asset('assets/kakao.png', height: 20),
                  backgroundColor: const Color(0xFFFEE500),
                  textColor: Colors.black,
                ),

                const SizedBox(height: 16),

                // Naver
                _SocialLoginButton(
                  text: 'Continue with Naver',
                  icon: Image.asset('assets/naver.png', height: 20),
                  backgroundColor: const Color(0xFF03C75A),
                  textColor: Colors.white,
                ),

                const SizedBox(height: 40),
                const Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final Color backgroundColor;
  final Color textColor;
  final bool border;

  const _SocialLoginButton({
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.border = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: icon,
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: border ? const BorderSide(color: Colors.grey) : BorderSide.none,
        ),
      ),
    );
  }
}
