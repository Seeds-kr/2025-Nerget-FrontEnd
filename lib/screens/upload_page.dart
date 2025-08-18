// lib/screens/upload_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _textCtrl = TextEditingController();
  final _picker = ImagePicker();
  final int _maxImages = 4;
  List<XFile> _images = [];
  bool _posting = false;

  bool get _canPost =>
      _textCtrl.text.trim().isNotEmpty || _images.isNotEmpty;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final remain = _maxImages - _images.length;
    if (remain <= 0) return;

    try {
      final picks = await _picker.pickMultiImage(
        imageQuality: 85, // 용량 줄임
      );

      setState(() {
        final toAdd = picks.take(remain);
        _images = [..._images, ...toAdd];
      });
    } catch (e) {
      // 필요시 스낵바 등 에러 처리
    }
  }

  void _removeImage(int idx) {
    setState(() => _images.removeAt(idx));
  }

  Future<void> _post() async {
    if (!_canPost || _posting) return;
    setState(() => _posting = true);

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _posting = false);
    Navigator.pop(context, true); // 업로드 성공 후 뒤로
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: _posting ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        title: const Text('새 게시물'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _canPost && !_posting ? _post : null,
            child: _posting
                ? const SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('게시하기'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 아바타 + 텍스트필드
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage('assets/avatar.png'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      onChanged: (_) => setState(() {}),
                      maxLines: null,
                      minLines: 3,
                      decoration: const InputDecoration(
                        hintText: '오늘의 OOTD는?',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 이미지 미리보기 (최대 4)
              if (_images.isNotEmpty) _PreviewGrid(files: _images, onRemove: _removeImage),

              const Spacer(),

              // 하단 툴바: 지금은 사진만
              Row(
                children: [
                  IconButton(
                    onPressed: (_images.length < _maxImages && !_posting) ? _pickImages : null,
                    icon: const Icon(Icons.image_outlined),
                    tooltip: '사진 추가',
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_images.length}/$_maxImages',
                    style: TextStyle(color: theme.hintColor),
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewGrid extends StatelessWidget {
  final List<XFile> files;
  final void Function(int index) onRemove;
  const _PreviewGrid({required this.files, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final count = files.length;
    if (count == 1) return _one(context, files.first, 0);
    if (count == 2) return _two(context, files);
    if (count == 3) return _three(context, files);
    return _four(context, files);
  }

  Widget _one(BuildContext context, XFile f, int idx) {
    return _tile(context, f, idx, BorderRadius.circular(12), aspect: 4 / 3);
  }

  Widget _two(BuildContext context, List<XFile> fs) {
    return Row(
      children: [
        Expanded(child: _tile(context, fs[0], 0,
            const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)))),
        const SizedBox(width: 6),
        Expanded(child: _tile(context, fs[1], 1,
            const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)))),
      ],
    );
  }

  Widget _three(BuildContext context, List<XFile> fs) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _tile(context, fs[0], 0,
              const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)), aspect: 4 / 5),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _tile(context, fs[1], 1,
                  const BorderRadius.only(topRight: Radius.circular(12)), aspect: 16 / 10),
              const SizedBox(height: 6),
              _tile(context, fs[2], 2,
                  const BorderRadius.only(bottomRight: Radius.circular(12)), aspect: 16 / 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _four(BuildContext context, List<XFile> fs) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _tile(context, fs[0], 0, const BorderRadius.only(topLeft: Radius.circular(12)))),
            const SizedBox(width: 6),
            Expanded(child: _tile(context, fs[1], 1, const BorderRadius.only(topRight: Radius.circular(12)))),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _tile(context, fs[2], 2, const BorderRadius.only(bottomLeft: Radius.circular(12)))),
            const SizedBox(width: 6),
            Expanded(child: _tile(context, fs[3], 3, const BorderRadius.only(bottomRight: Radius.circular(12)))),
          ],
        ),
      ],
    );
  }

  Widget _tile(BuildContext context, XFile f, int idx, BorderRadius radius, {double aspect = 1}) {
    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: aspect,
            child: Image.file(File(f.path), fit: BoxFit.cover),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: InkWell(
              onTap: () => onRemove(idx),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
