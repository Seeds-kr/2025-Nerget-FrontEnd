import 'package:google_sign_in/google_sign_in.dart' show GoogleSignInAccount;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:js/js.dart';
import 'package:js/js_util.dart' as js_util;

/// ── GSI JS interop ─────────────────────────────────────────────
@JS('google.accounts.id.initialize')
external void _gsiInitialize(IdConfiguration config);

@JS('google.accounts.id.renderButton')
external void _gsiRenderButton(
  html.HtmlElement parent,
  ButtonConfiguration options,
);

@JS('google.accounts.id.prompt')
external void _gsiPrompt([Function? cb]);

@JS()
@anonymous
class IdConfiguration {
  external String? get client_id;
  external Function? get callback;
  external bool? get auto_select;
  external String? get ux_mode;
  external factory IdConfiguration({
    String? client_id,
    Function? callback,
    bool? auto_select,
    String? ux_mode,
  });
}

@JS()
@anonymous
class ButtonConfiguration {
  external String? get theme;
  external String? get size;
  external String? get type;
  external String? get shape;
  external factory ButtonConfiguration({
    String? theme,
    String? size,
    String? type,
    String? shape,
  });
}

/// ── 리포지토리 웹 구현 ─────────────────────────────────────────────
class AuthRepository {
  AuthRepository();

  void Function(String idToken)? onIdToken;

  static const String _webClientId = String.fromEnvironment(
    'GSI_CLIENT_ID',
    defaultValue:
        '1076507336995-uo4b83nsjjc24rcot71546lntebifp5k.apps.googleusercontent.com',
  );

  bool _inited = false;

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    _ensureInitialized();
    _gsiPrompt(); // 원탭/팝업 시도
    return null;
  }

  void renderGoogleButton(String containerId) {
    _ensureInitialized();

    void waitReady(num _) {
      final google = js_util.getProperty(html.window, 'google');
      final el = html.document.getElementById(containerId);

      if (google == null || el == null) {
        // ignore: avoid_print
        if (google == null) print('[GSI] window.google not ready, waiting...');
        // ignore: avoid_print
        if (el == null)
          print('[GSI] container #$containerId not attached yet, waiting...');
        html.window.requestAnimationFrame(waitReady);
        return;
      }

      // ignore: avoid_print
      print('[GSI] renderButton into #$containerId');
      _gsiRenderButton(
        el as html.HtmlElement,
        ButtonConfiguration(
          theme: 'filled_blue',
          size: 'large',
          type: 'standard',
          shape: 'rectangular',
        ),
      );
    }

    html.window.requestAnimationFrame(waitReady);
  }

  void _ensureInitialized() {
    if (_inited) return;

    // ignore: avoid_print
    print('[GSI] initialize with client_id=$_webClientId');

    _gsiInitialize(
      IdConfiguration(
        client_id: _webClientId,
        ux_mode: 'popup',
        auto_select: false,
        callback: allowInterop((dynamic resp) {
          final token = js_util.getProperty(resp, 'credential') as String?;
          // ignore: avoid_print
          print('[GSI] credential received? ${token != null}');
          final cb = onIdToken;
          if (token != null && cb != null) cb(token);
        }),
      ),
    );

    _inited = true;
  }
}
