import 'package:flutter/material.dart';
import 'package:omakase_app/shared/repository/auth_repository.dart';

// Web 전용
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// Flutter Web에서 platformViewRegistry 제공
import 'dart:ui_web' as ui_web;
// window.google 존재 확인용
import 'package:js/js_util.dart' as js_util;

class GoogleSignInButtonImpl extends StatefulWidget {
  final AuthRepository authRepository;
  final bool isLoading;
  final VoidCallback? onPressed; // 모바일과 인터페이스 통일용

  const GoogleSignInButtonImpl({
    super.key,
    required this.authRepository,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  State<GoogleSignInButtonImpl> createState() => _GoogleSignInButtonImplState();
}

class _GoogleSignInButtonImplState extends State<GoogleSignInButtonImpl> {
  late final String _viewTypeForThisInstance =
      'gsi-btn-${DateTime.now().microsecondsSinceEpoch}';
  late final String _containerId =
      'gsi-container-${DateTime.now().microsecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();

    // gsi/client 스크립트 주입(중복 주입에 안전)
    final hasGoogle = js_util.getProperty(html.window, 'google');
    if (hasGoogle == null &&
        html.document.querySelector(
              'script[src="https://accounts.google.com/gsi/client"]',
            ) ==
            null) {
      final script = html.ScriptElement()
        ..src = 'https://accounts.google.com/gsi/client'
        ..async = true
        ..defer = true;
      html.document.head?.append(script);
    }

    // 1) 유니크 viewFactory 등록
    ui_web.platformViewRegistry.registerViewFactory(_viewTypeForThisInstance, (
      int _,
    ) {
      final root = html.DivElement()
        ..id = _containerId
        ..style.width = '240px'
        ..style.height = '48px'
        ..style.display = 'block';
      return root;
    });

    // 2) 버튼 렌더 (window.google 로딩 이후)
    html.window.requestAnimationFrame((_) {
      widget.authRepository.renderGoogleButton(_containerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: 240,
          height: 48,
          child: HtmlElementView(viewType: _viewTypeForThisInstance),
        ),
        if (widget.isLoading)
          Positioned.fill(
            child: Container(
              color: const Color.fromRGBO(0, 0, 0, 0.06),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
          ),
      ],
    );
  }
}
