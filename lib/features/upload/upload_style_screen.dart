import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadStyleScreen extends StatefulWidget {
  const UploadStyleScreen({super.key});

  @override
  State<UploadStyleScreen> createState() => _UploadStyleScreenState();
}

class _UploadStyleScreenState extends State<UploadStyleScreen> {
  final _picker = ImagePicker();
  XFile? _picked;
  final _caption = TextEditingController();
  bool _posting = false;

  Future<void> _pickImage() async {
    try {
      final img = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800, maxHeight: 1800, imageQuality: 90,
      );
      if (img != null) setState(() => _picked = img);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('업로드 실패: $e')));
    }
  }

  Future<void> _post() async {
    if (_picked == null) {
      _pickImage();
      return;
    }
    setState(() => _posting = true);
    try {
      // TODO: 실제 업로드(API/S3) 연동
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('게시 완료!')));
      _caption.clear();
      setState(() => _picked = null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('실패: $e')));
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF111111);
    const divider = Color(0xFFEAEAEA);
    const lightGray = Color(0xFFF5F5F5);
    final hasImage = _picked != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            child: ListView(
              children: [
                // 업로드 영역
                AspectRatio(
                  aspectRatio: 1,
                  child: InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: lightGray,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: divider),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: hasImage
                          ? (kIsWeb
                          ? const Center(child: Text('웹 미리보기는 추후 지원'))
                          : Image.file(File(_picked!.path), fit: BoxFit.cover))
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_a_photo_outlined, size: 56, color: black),
                          SizedBox(height: 8),
                          Text('Tap to upload', style: TextStyle(color: black)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 캡션
                TextField(
                  controller: _caption,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Write a caption...',
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: divider),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: black, width: 1.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ],
            ),
          ),
          // 하단 버튼
          Positioned(
            left: 16, right: 16, bottom: 16,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _posting ? null : _post,
                style: ElevatedButton.styleFrom(
                  backgroundColor: black, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(hasImage ? 'Post' : 'Upload a photo'),
              ),
            ),
          ),
          if (_posting)
            Positioned.fill(
              child: Container(
                color: const Color(0x08000000),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
