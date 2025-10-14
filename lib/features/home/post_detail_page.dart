import 'package:flutter/material.dart';
import 'package:omakase_app/features/models/post.dart';
import 'package:omakase_app/features/state/app_state.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;
  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController commentController = TextEditingController();
  late Post _currentPost;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    final wasLiked = _currentPost.liked;
    // 화면에 즉시 반영하기 위해 setState 사용
    setState(() {
      _currentPost = _currentPost.copyWith(
        liked: !wasLiked,
        likeCount: wasLiked ? _currentPost.likeCount - 1 : _currentPost.likeCount + 1,
      );
    });
    // 앱의 다른 개발자를 위해 전역 상태 업데이트는 그대로 둡니다.
    context.app.toggleLike(widget.post.id);
  }

  void _toggleSave() {
    final wasSaved = _currentPost.saved;
    setState(() {
      _currentPost = _currentPost.copyWith(saved: !wasSaved);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(!wasSaved ? '저장했어요' : '저장을 취소했어요')),
    );
    context.app.toggleSave(widget.post.id);
  }

  void _addComment() {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _currentPost = _currentPost.copyWith(
        comments: [text, ..._currentPost.comments],
        commentCount: _currentPost.commentCount + 1,
      );
    });
    context.app.addComment(widget.post.id, text);
    commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물'),
        actions: [
          IconButton(
            tooltip: _currentPost.saved ? '저장 취소' : '저장',
            icon: Icon(_currentPost.saved ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleSave,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 300, child: _buildGallery(_currentPost)),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _currentPost.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _currentPost.description ?? '',
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                '${_currentPost.createdAt.toLocal()} • ❤️ ${_currentPost.likeCount} • 💬 ${_currentPost.commentCount}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _currentPost.liked ? Icons.favorite : Icons.favorite_border,
                      color: _currentPost.liked ? Colors.red : Colors.grey,
                    ),
                    onPressed: _toggleLike,
                  ),
                  const Text('좋아요'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _currentPost.comments
                    .map((c) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('💬 $c')))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(hintText: '댓글을 입력하세요', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addComment,
                    child: const Text('등록'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGallery(Post post) {
    if (post.images.isNotEmpty) {
      return PageView.builder(
        itemCount: post.images.length,
        itemBuilder: (_, i) => _buildImage(post.images[i]),
      );
    }
    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      return _buildImage(post.imageUrl!);
    }
    return const Center(
      child: Icon(Icons.image_not_supported, size: 40, color: Colors.black26),
    );
  }

  Widget _buildImage(String src) {
    final isNetwork = src.startsWith('http://') || src.startsWith('https://');
    final img = isNetwork
        ? Image.network(
            src,
            fit: BoxFit.contain,
            cacheWidth: 1200,
            filterQuality: FilterQuality.low,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, size: 36, color: Colors.black26),
            )
          )
        : Image.asset(
            src,
            fit: BoxFit.contain,
            cacheWidth: 1200,
            filterQuality: FilterQuality.low,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, size: 36, color: Colors.black26),
            ),
          );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: img),
    );
  }
}
