import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class StyleApi {
  final ApiClient _api = ApiClient();

  static const _uploadPath = '/api/style/analyze';
  static const _skipPath = '/api/style/analyze/skip';
  static const _mbtiPath = '/api/style/mbti';
  static const _feedPath = '/api/style/recommend';

  // ❗️요구 사항: 단일 필드명으로 최대 4장. 동일 키 반복 업로드.
  static const _fieldName = 'image';

  Future<void> uploadInitialPhotos(List<PlatformFile> files) async {
    final selected = files.take(4).toList();
    final parts = <http.MultipartFile>[];

    for (final f in selected) {
      if (kIsWeb) {
        if (f.bytes == null) continue;
        parts.add(
          http.MultipartFile.fromBytes(_fieldName, f.bytes!, filename: f.name),
        );
      } else {
        if (f.path == null) continue;
        parts.add(await http.MultipartFile.fromPath(_fieldName, f.path!));
      }
    }

    final res = await _api.multipart(_uploadPath, parts);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final body = await res.stream.bytesToString();
      throw Exception('Upload failed (${res.statusCode}): $body');
    }
  }

  Future<void> skipInitialUpload() async {
    final res = await _api.post(_skipPath);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Skip failed (${res.statusCode}): ${res.body}');
    }
  }

  // 구조만: 나중에 홈에서 사용
  Future<String?> fetchMbti() async {
    final res = await _api.get(_mbtiPath);
    if (res.statusCode == 200) {
      // 서버가 {"mbti":"ISTP"} 같은 형태라고 가정
      return (res.body.contains('mbti'))
          ? RegExp(r'"mbti"\s*:\s*"([^"]+)"').firstMatch(res.body)?.group(1)
          : null;
    }
    return null;
  }

  Future<List<dynamic>> fetchRecommendedFeed() async {
    final res = await _api.get(_feedPath);
    if (res.statusCode == 200) {
      // 실제 스키마 오면 여기에 파싱
      return [];
    }
    throw Exception('Recommend failed: ${res.statusCode}');
  }
}
