import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:omakase_app/shared/api/env.dart' as appenv;

class OnboardingUploadScreen extends StatefulWidget {
  const OnboardingUploadScreen({super.key});

  @override
  State<OnboardingUploadScreen> createState() => _OnboardingUploadScreenState();
}

class _OnboardingUploadScreenState extends State<OnboardingUploadScreen> {
  // ▶ 스와이프 화면 라우트명: 프로젝트에 맞게 바꿔도 됨
  static const String _nextRoute = '/swipe';

  final Dio _dio = Dio();
  final List<PlatformFile> _files = [];
  bool _uploading = false;

  // 이미지 선택 (최대 4장)
  Future<void> _onPickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );
      if (result == null) return;
      setState(() {
        _files
          ..clear()
          ..addAll(result.files.take(4));
      });
    } catch (e) {
      if (!mounted) return;
      _showSnack('이미지 선택 오류: $e');
    }
  }

  // 업로드 -> 성공 시 true
  Future<bool> _uploadImages() async {
    if (_files.isEmpty) return true; // 파일 없으면 그냥 통과(스킵과 동일 플로우)

    try {
      setState(() => _uploading = true);

      final mpFiles = <MultipartFile>[];
      for (final f in _files) {
        final Uint8List? bytes = f.bytes;
        if (bytes == null) {
          _showSnack('파일 바이트를 읽지 못했어요: ${f.name}');
          setState(() => _uploading = false);
          return false;
        }
        mpFiles.add(MultipartFile.fromBytes(bytes, filename: f.name));
      }

      final form = FormData.fromMap({
        'images': mpFiles, // 서버 필드명 다르면 이 부분만 바꿔주세요.
      });

      final url = '${appenv.Env.apiBaseUrl()}/api/style/analyze';
      final resp = await _dio.post(url, data: form);
      final ok = (resp.statusCode ?? 500) ~/ 100 == 2;
      if (!ok) {
        _showSnack('업로드 실패: ${resp.statusCode}');
        setState(() => _uploading = false);
        return false;
      }

      setState(() => _uploading = false);
      return true;
    } catch (e) {
      _showSnack('업로드 오류: $e');
      setState(() => _uploading = false);
      return false;
    }
  }

  // 업로드 후 다음 단계로
  Future<void> _handleUploadAndNext() async {
    if (_uploading) return;
    // 업로드 절차 없이 바로 이동
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(_nextRoute);
  }

  // 스킵 → 바로 스와이프
  void _handleSkip() {
    if (_uploading) return;
    Navigator.of(context).pushReplacementNamed(_nextRoute);
    // go_router: context.go(_nextRoute);
  }

  void _showSnack(String msg) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 0, 16, 96 + bottomInset),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final isPhoneLike = size.width < 600;

    // 업로드 박스 높이(조금 크게)
    double boxHeight = isPhoneLike ? size.height * 0.32 : size.height * 0.40;
    boxHeight = boxHeight.clamp(220.0, isPhoneLike ? 360.0 : 460.0);

    final grayText = Colors.black.withOpacity(0.45);
    final border = Colors.black.withOpacity(0.08);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: Colors.black,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Text(
          'Survey',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Your Own Style Photos.',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Up to 4 outfit photos',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: grayText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // 업로드 영역
              GestureDetector(
                onTap: _uploading ? null : _onPickImages,
                child: Container(
                  width: double.infinity,
                  height: boxHeight,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: border),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_files.isEmpty)
                        const Icon(
                          Icons.image_outlined,
                          size: 36,
                          color: Colors.white70,
                        ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: border),
                          ),
                          child: Text(
                            '${_files.length.clamp(0, 4)} / 4',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      if (_files.isNotEmpty)
                        LayoutBuilder(
                          builder: (context, c) {
                            final w = c.maxWidth;
                            final h = c.maxHeight;
                            final itemW = (w - 24) / 2;
                            final itemH = (h - 24) / 2;

                            Widget thumb(PlatformFile f) {
                              if (f.bytes == null) {
                                return Container(
                                  color: Colors.black.withOpacity(0.15),
                                  child: const Icon(Icons.image, size: 24),
                                );
                              }
                              return Image.memory(f.bytes!, fit: BoxFit.cover);
                            }

                            return Padding(
                              padding: const EdgeInsets.all(8),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(_files.length, (i) {
                                  return SizedBox(
                                    width: itemW,
                                    height: itemH,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: thumb(_files[i]),
                                    ),
                                  );
                                }),
                              ),
                            );
                          },
                        ),
                      if (_uploading)
                        Container(
                          color: Colors.black.withOpacity(0.1),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Upload & Continue
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _uploading ? null : _handleUploadAndNext,
                  child: Text(
                    _uploading ? 'Uploading…' : 'Upload',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Skip
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _uploading ? null : _handleSkip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
