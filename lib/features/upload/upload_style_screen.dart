import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:omakase_app/shared/api/env.dart' as appenv;
import 'package:omakase_app/router/app_router.dart';
import 'package:omakase_app/shared/api/prefs.dart';

class UploadStyleScreen extends StatefulWidget {
  const UploadStyleScreen({super.key});

  @override
  State<UploadStyleScreen> createState() => _UploadStyleScreenState();
}

class _UploadStyleScreenState extends State<UploadStyleScreen> {
  PlatformFile? _picked;
  final TextEditingController _textController = TextEditingController();
  final Dio _dio = Dio();
  bool _uploading = false;

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

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      setState(() => _picked = result.files.single);
    } catch (e) {
      if (!mounted) return;
      _showSnack('이미지 선택 오류: $e');
    }
  }

  Future<bool> _uploadImage() async {
    if (_picked == null) return true;
    try {
      setState(() => _uploading = true);

      // If mock mode is enabled, simulate a successful upload so flows work offline.
      if (appenv.Env.useMock) {
        await Future.delayed(const Duration(milliseconds: 600));
        setState(() => _uploading = false);
        return true;
      }

      Uint8List? bytes = _picked!.bytes;
      if (bytes == null && _picked!.path != null) {
        bytes = await File(_picked!.path!).readAsBytes();
      }

      if (bytes == null) {
        _showSnack('파일을 읽을 수 없습니다.');
        setState(() => _uploading = false);
        return false;
      }

      final mp = MultipartFile.fromBytes(bytes, filename: _picked!.name);
      final form = FormData.fromMap({
        'images': [mp],
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

  Future<void> _complete(BuildContext context) async {
    if (_uploading) return;
    final ok = await _uploadImage();
    if (!ok || !mounted) return;

    // show a simple success message, then proceed
    _showSnack('게시글 업로드 성공');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKeys.profileCompleted, true);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.feed);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 게시물'),
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소', style: TextStyle(color: Colors.white)),
        ),
        actions: [
          TextButton(
            onPressed: () => _complete(context),
            child: const Text('게시하기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/feed_style18.jpg'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: '오늘의 ootd는?',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      maxLines: null,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: _picked == null
                      ? const Text(
                          '사진을 추가하세요',
                          style: TextStyle(color: Colors.black45),
                        )
                      : (_picked!.bytes != null
                            ? Image.memory(_picked!.bytes!, fit: BoxFit.contain)
                            : (_picked!.path != null
                                  ? Image.file(
                                      File(_picked!.path!),
                                      fit: BoxFit.contain,
                                    )
                                  : const Text('미리보기를 불러올 수 없습니다'))),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: _picked == null
                          ? const Icon(Icons.photo, color: Colors.black45)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: (_picked!.bytes != null
                                  ? Image.memory(
                                      _picked!.bytes!,
                                      fit: BoxFit.cover,
                                    )
                                  : (_picked!.path != null
                                        ? Image.file(
                                            File(_picked!.path!),
                                            fit: BoxFit.cover,
                                          )
                                        : const SizedBox.shrink())),
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_picked == null ? 0 : 1}/1',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: (_picked != null && !_uploading)
                        ? () => _complete(context)
                        : null,
                    child: _uploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('게시하기'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
