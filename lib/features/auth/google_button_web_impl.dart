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
  // 인스턴스마다 유니크한 viewType / containerId 생성 (핫리로드/하드리로드 안전)
  late final String _containerId;
  late final String _viewTypeForThisInstance;

  @override
  void initState() {
    super.initState();

    final stamp = DateTime.now().microsecondsSinceEpoch;
    _containerId = 'gsi-button-container-$stamp';
    _viewTypeForThisInstance = 'gsi_button_view_$stamp';

    // 0) GSI 스크립트가 head에 없으면 직접 주입 (index.html 누락해도 동작)
    if (html.document.head != null &&
        html.document.getElementById('gsi-client') == null) {
      final s =
          html.ScriptElement()
            ..id = 'gsi-client'
            ..src = 'https://accounts.google.com/gsi/client'
            ..async = true
            ..defer = true;
      html.document.head!.append(s);
      // ignore: avoid_print
      print('[GSI] injected gsi/client script');
    }

    // 1) 유니크 viewFactory 등록 (인스턴스마다 한 번)
    ui_web.platformViewRegistry.registerViewFactory(_viewTypeForThisInstance, (
      int _,
    ) {
      final root =
          html.DivElement()
            ..id = _containerId
            ..style.width = '240px'
            ..style.height = '48px'
            ..style.display = 'block';
      return root; // HtmlElement 반환
    });

    // 2) DOM 부착 + GSI 스크립트 로드를 모두 기다렸다가 렌더
    WidgetsBinding.instance.addPostFrameCallback((_) {
      void waitReady(num _) {
        final hasContainer = html.document.getElementById(_containerId) != null;
        final hasGoogle = js_util.getProperty(html.window, 'google') != null;
        if (!hasContainer || !hasGoogle) {
          html.window.requestAnimationFrame(waitReady);
          return;
        }
        // ignore: avoid_print
        print('[GSI] renderButton on #$_containerId');
        widget.authRepository.renderGoogleButton(_containerId);
      }

      html.window.requestAnimationFrame(waitReady);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 부모가 사이즈를 주지 않으면 0x0로 안 보일 수 있으므로 고정 크기
    return SizedBox(
      width: 240,
      height: 48,
      child: HtmlElementView(viewType: _viewTypeForThisInstance),
    );
  }
}
