import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../router/app_router.dart';
import '../../shared/api/style_api.dart';
import 'package:omakase_app/shared/api/prefs.dart';

class OnboardingUploadScreen extends StatefulWidget {
  const OnboardingUploadScreen({super.key});
  @override
  State<OnboardingUploadScreen> createState() => _OnboardingUploadScreenState();
}

class _OnboardingUploadScreenState extends State<OnboardingUploadScreen> {
  final _api = StyleApi();
  bool _loading = false;
  List<PlatformFile> _files = [];

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
      ).showSnackBar(const SnackBar(content: Text('사진을 선택해주세요 (최대 4장)')));
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.uploadInitialPhotos(_files);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PrefKeys.onboarding, 'swipe');
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.swipe);
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
      await _api.skipInitialUpload();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PrefKeys.onboarding, 'swipe');
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.swipe);
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
