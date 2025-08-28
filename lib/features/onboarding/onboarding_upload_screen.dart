import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:omakase_app/features/onboarding/swipe_test_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:omakase_app/router/app_router.dart';
import '../../shared/api/style_api.dart';
import 'package:omakase_app/shared/api/prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:omakase_app/shared/api/api_client.dart';
import 'package:omakase_app/shared/api/env.dart' as appenv;

class OnboardingUploadScreen extends StatefulWidget {
  const OnboardingUploadScreen({super.key});
  @override
  State<OnboardingUploadScreen> createState() => _OnboardingUploadScreenState();
}

class _OnboardingUploadScreenState extends State<OnboardingUploadScreen> {
  final Dio _mockDio = Dio(
    BaseOptions(
      baseUrl: appenv.Env.apiBaseUrl(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final _api = StyleApi();
  bool _loading = false;
  List<PlatformFile> _files = [];

  Future<List<String>> _encodeSelectedImagesB64() async {
    final result = <String>[];

    for (final f in _files) {
      // FilePicker PlatformFile(bytes) 우선 사용
      final dynamic maybeBytes = (f as dynamic).bytes;
      if (maybeBytes is List<int>) {
        result.add(base64Encode(maybeBytes));
        continue;
      }

      // XFile 처럼 readAsBytes()가 있는 경우
      if ((f as dynamic).readAsBytes != null) {
        final bytes = await (f as dynamic).readAsBytes();
        result.add(base64Encode(bytes));
        continue;
      }

      // 웹에서 path 로 File 읽기는 불가. withData: true 로 선택하도록 유도.
      if (kIsWeb) {
        throw Exception('웹에서는 bytes가 필요합니다. 파일 선택 시 withData: true 로 설정해 주세요.');
      }

      // (모바일 전용) path 가 있으면 File 로 읽기
      final String? path = (f as dynamic).path as String?;
      if (path != null) {
        // ignore: avoid_web_libraries_in_flutter
        // dart:io를 못 쓰는 웹에서 이 분기는 호출되지 않음
        // 아래 라인은 모바일 빌드에서만 컴파일/사용됨
        // (웹 빌드에서 경고가 보이면 분리해도 되지만, 보통 문제 없이 빌드됩니다)
        // import 'dart:io'; 가 없다면 이 분기는 사용되지 않습니다.
        // 만약 android/ios에서도 web과 같은 코드로 가고 싶다면 위 두 케이스만 사용하세요.
        // final bytes = await File(path).readAsBytes();
        // result.add(base64Encode(bytes));
        throw Exception('모바일에서만 path 읽기 허용. (현재 웹)');
      } else {
        throw Exception('이미지 바이트를 읽을 수 없습니다.');
      }
    }

    return result;
  }

  Future<void> _pick() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (r != null) setState(() => _files = r.files.take(4).toList());
  }

  Future<void> _upload() async {
    if (_files.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('최소 1장의 이미지를 선택해 주세요.')));
      return;
    }

    setState(() => _loading = true);
    try {
      if (appenv.Env.useMock) {
        // ✅ mock: json-server는 JSON만 파싱 → base64 배열로 전송
        final imagesB64 = await _encodeSelectedImagesB64();

        await _mockDio.post(
          '/api/style/analyze', // routes.json에서 /style/analyze 로 rewrite됨
          data: {'images': imagesB64},
          options: Options(contentType: Headers.jsonContentType),
        );
      } else {
        // ✅ 실서버: 네가 쓰던 기존 멀티파트 업로드 호출 유지
        await StyleApi().uploadInitialPhotos(_files);
      }

      // 성공 → 다음 단계
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PrefKeys.onboarding, 'swipe');

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacementNamed(AppRoutes.Swipe); // 라우트 키 소문자 확인
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('업로드 실패: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _skip() async {
    setState(() => _loading = true);
    try {
      if (!appenv.Env.useMock) {
        // 실서버일 때만 기존 스킵 API 호출
        await StyleApi().skipInitialUpload();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PrefKeys.onboarding, 'swipe');

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.Swipe);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('건너뛰기 실패: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('온보딩: 초기 사진 업로드')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '최초 로그인 시 최대 4장 업로드',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: _files.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (_, i) {
                  if (i == _files.length) {
                    return OutlinedButton.icon(
                      onPressed: _loading ? null : _pick,
                      icon: const Icon(Icons.add),
                      label: const Text('추가'),
                    );
                  }
                  final f = _files[i];
                  return Stack(
                    children: [
                      Positioned.fill(
                        child:
                            (f.bytes != null)
                                ? Image.memory(f.bytes!, fit: BoxFit.cover)
                                : Container(
                                  alignment: Alignment.center,
                                  child: Text(f.name),
                                ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap:
                              _loading
                                  ? null
                                  : () => setState(() => _files.removeAt(i)),
                          child: const CircleAvatar(
                            radius: 12,
                            child: Icon(Icons.close, size: 14),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : _skip,
                    child: const Text('건너뛰기'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _loading ? null : _upload,
                    child: Text(_loading ? '업로드 중...' : '업로드하고 계속'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
