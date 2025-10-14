import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omakase_app/router/app_router.dart';

class OnboardingUploadScreen extends StatefulWidget {
  const OnboardingUploadScreen({super.key});

  @override
  State<OnboardingUploadScreen> createState() => _OnboardingUploadScreenState();
}

class _OnboardingUploadScreenState extends State<OnboardingUploadScreen> {
  final _picker = ImagePicker();
  XFile? _picked;

  Future<void> _pickImage() async {
    try {
      final XFile? img = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 90,
      );
      if (img != null) {
        setState(() => _picked = img);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택 실패: $e')),
      );
    }
  }

  void _skip() {
    Navigator.of(context).pushNamed(AppRoutes.swipeTest);
  }

  void _nextIfSelected() {
    if (_picked == null) {
      // 업로드 버튼은 “선택” 역할이라 여기선 안내만
      _pickImage();
      return;
    }
    // TODO: 여기에 서버 업로드/스토리지 업로드 로직 연결 가능
    Navigator.of(context).pushNamed(
      AppRoutes.swipeTest,
      arguments: {'profileImagePath': _picked!.path},
    );
  }

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF111111);
    const divider = Color(0xFFEAEAEA);
    const lightGray = Color(0xFFF5F5F5);
    const accentGray = Color(0xFF7A7A7A);

    final hasImage = _picked != null;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('옷마카세', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // 업로드 영역
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: lightGray,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: divider),
                ),
                clipBehavior: Clip.antiAlias,
                child: hasImage
                    ? _PreviewImage(file: _picked!)
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.camera_alt, size: 64, color: accentGray),
                    SizedBox(height: 8),
                    Text('Upload Photo', style: TextStyle(color: black)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Upload a photo that represents your style',
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            // 하단 고정 액션 Row: Skip / Upload or Next
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _skip,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: black),
                      foregroundColor: black,
                    ),
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextIfSelected,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(hasImage ? 'Next' : 'Upload'),
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

class _PreviewImage extends StatelessWidget {
  final XFile file;
  const _PreviewImage({required this.file});

  @override
  Widget build(BuildContext context) {
    // 웹은 File API가 다름 → 여기선 앱만 사용하므로 kIsWeb 분기로 처리
    if (kIsWeb) {
      return const Center(
        child: Text('웹 프리뷰는 추후 지원 예정'),
      );
    }
    return Image.file(
      File(file.path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.broken_image_outlined, size: 48),
      ),
    );
  }
}
