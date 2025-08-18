import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'env.dart';

class ApiClient {
  final http.Client _client = http.Client();

  Future<Map<String, String>> _headers({bool json = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final h = <String, String>{'Accept': 'application/json'};
    if (json) h['Content-Type'] = 'application/json';
    if (token != null && token.isNotEmpty) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Uri _url(String path) => Uri.parse('${Env.apiBaseUrl()}$path');

  Future<http.Response> post(String path, {Map<String, dynamic>? body}) async {
    return _client.post(
      _url(path),
      headers: await _headers(json: true),
      body: jsonEncode(body ?? {}),
    );
  }

  Future<http.Response> get(String path) async {
    return _client.get(_url(path), headers: await _headers());
  }

  Future<http.StreamedResponse> multipart(
    String path,
    List<http.MultipartFile> files,
  ) async {
    final req = http.MultipartRequest('POST', _url(path));
    req.headers.addAll(await _headers());
    req.files.addAll(files);
    return req.send();
  }
}
