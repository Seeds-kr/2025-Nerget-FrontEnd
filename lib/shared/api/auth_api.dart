import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' as browser_http;
import 'package:shared_preferences/shared_preferences.dart';
import 'env.dart';

class AuthResult {
  final bool ok;
  final bool isNewUser;
  final String token;
  AuthResult({required this.ok, required this.isNewUser, required this.token});
}

class AuthApi {
  /// 서버가 세션쿠키 기반 인증이면 true, JWT(Authorization 헤더)면 false
  static const bool useCookieSession = false;

  http.Client _client() {
    if (kIsWeb) {
      final c = browser_http.BrowserClient();
      c.withCredentials = useCookieSession; // 세션 쿠키 방식일 때만 true
      return c;
    }
    return http.Client();
  }

  Uri _u(String path) {
    var base = Env.apiBaseUrl();
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    return Uri.parse('$base$path');
  }

  /// me 경로는 실행 옵션으로 덮어쓸 수 있게
  static const String _mePathFromDefine = String.fromEnvironment(
    'API_ME_PATH',
    defaultValue: '/api/auth/me',
  );

  /// 로그인: ID 토큰 → 서버, 서버는 앱 토큰(JWT 등)과 신규여부 반환
  Future<AuthResult> loginWithGoogle(String idToken) async {
    final client = _client();
    try {
      final headers = <String, String>{'content-type': 'application/json'};
      final bodyJson = jsonEncode({'idToken': idToken});

      debugPrint('[AuthApi] POST ${_u('/api/auth/google')}');
      debugPrint('[AuthApi] headers=$headers');
      debugPrint('[AuthApi] body=$bodyJson');

      final res = await client.post(
        _u('/api/auth/google'),
        headers: headers,
        body: bodyJson,
      );

      debugPrint('[AuthApi] => status=${res.statusCode} body=${res.body}');
      if (res.statusCode < 200 || res.statusCode >= 300) {
        return AuthResult(ok: false, isNewUser: false, token: '');
      }

      final j = (jsonDecode(res.body) as Map).cast<String, dynamic>();
      final token =
          (j['token'] ?? j['accessToken'] ?? j['jwt'] ?? '') as String;
      final isNew =
          (j['new'] ?? j['isNewUser'] ?? j['is_new'] ?? false) as bool;

      if (token.isNotEmpty) {
        final sp = await SharedPreferences.getInstance();
        await sp.setString('access_token', token);
      }
      return AuthResult(ok: true, isNewUser: isNew, token: token);
    } finally {
      client.close();
    }
  }

  /// 보호 API: 여러 방식/경로를 순차 시도해서 me 정보를 가져옴
  Future<Map<String, dynamic>> me({String? token}) async {
    final client = _client();
    try {
      // ✅ nullable 토큰을 미리 non-null 로 정리
      final sp = await SharedPreferences.getInstance();
      final tok = (token ?? sp.getString('access_token') ?? '').trim();

      final baseHeaders = <String, String>{'accept': 'application/json'};
      final withBearer =
          tok.isNotEmpty
              ? <String, String>{...baseHeaders, 'authorization': 'Bearer $tok'}
              : baseHeaders;

      final paths =
          <String>{
            _mePathFromDefine,
            '/api/users/me',
            '/api/me',
            '/auth/me',
            '/users/me',
          }.toList();

      for (final p in paths) {
        // 1) GET + Bearer
        debugPrint('[AuthApi][ME] TRY GET Bearer ${_u(p)}');
        var r = await client.get(_u(p), headers: withBearer);
        debugPrint('[AuthApi][ME] <= ${r.statusCode} ${r.body}');
        if (r.statusCode >= 200 && r.statusCode < 300) {
          return (jsonDecode(r.body) as Map).cast<String, dynamic>();
        }

        // 2) GET (쿠키 세션)
        debugPrint('[AuthApi][ME] TRY GET Cookie ${_u(p)}');
        r = await client.get(_u(p), headers: baseHeaders);
        debugPrint('[AuthApi][ME] <= ${r.statusCode} ${r.body}');
        if (r.statusCode >= 200 && r.statusCode < 300) {
          return (jsonDecode(r.body) as Map).cast<String, dynamic>();
        }

        if (tok.isNotEmpty) {
          // 3) POST JSON {token}
          debugPrint('[AuthApi][ME] TRY POST JSON ${_u(p)}');
          r = await client.post(
            _u(p),
            headers: {...baseHeaders, 'content-type': 'application/json'},
            body: jsonEncode({'token': tok}),
          );
          debugPrint('[AuthApi][ME] <= ${r.statusCode} ${r.body}');
          if (r.statusCode >= 200 && r.statusCode < 300) {
            return (jsonDecode(r.body) as Map).cast<String, dynamic>();
          }

          // 4) POST FORM token=...
          debugPrint('[AuthApi][ME] TRY POST FORM ${_u(p)}');
          r = await client.post(
            _u(p),
            headers: {
              ...baseHeaders,
              'content-type': 'application/x-www-form-urlencoded',
            },
            body: 'token=${Uri.encodeComponent(tok)}',
          );
          debugPrint('[AuthApi][ME] <= ${r.statusCode} ${r.body}');
          if (r.statusCode >= 200 && r.statusCode < 300) {
            return (jsonDecode(r.body) as Map).cast<String, dynamic>();
          }
        }
        // 다음 경로로 계속
      }

      throw Exception(
        'ME endpoint not compatible (tried multiple methods/paths).',
      );
    } finally {
      client.close();
    }
  }

  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('access_token');
  }
}
