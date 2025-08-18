import 'dart:convert';
import 'api_client.dart';

class AuthResponse {
  final bool isNewUser;
  final String accessToken;
  AuthResponse({required this.isNewUser, required this.accessToken});

  factory AuthResponse.fromJson(Map<String, dynamic> j) => AuthResponse(
    isNewUser: (j['isNewUser'] ?? j['newUser'] ?? j['is_new'] ?? false) as bool,
    accessToken: (j['accessToken'] ?? j['token'] ?? '') as String,
  );
}

class AuthApi {
  final ApiClient _api = ApiClient();

  // 백엔드가 기대하는 키가 idToken이라 가정 (필요 시 'token' 등으로 바꿔도 한 줄)
  Future<AuthResponse> loginWithGoogle(String idToken) async {
    final res = await _api.post('/api/auth/google', body: {'idToken': idToken});
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Auth failed (${res.statusCode}): ${res.body}');
    }
    return AuthResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}
