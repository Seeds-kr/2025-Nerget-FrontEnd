import 'package:flutter/material.dart';
import 'package:nuget_application/models/post.dart';
import 'package:nuget_application/state/app_state.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;
  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  bool isLiked = false;
  final TextEditingController commentController = TextEditingController();
  final List<String> comments = [];

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;

    // 항상 최신 상태의 Post를 전역 리스트에서 찾아서 사용
    final Post current = app.posts.firstWhere(
          (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물'),
        actions: [
          IconButton(
            tooltip: current.saved ? '저장 취소' : '저장',
            icon: Icon(current.saved ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () {
              app.toggleSave(current.id);   // 전역 상태 토글
              setState(() {});              // 아이콘 갱신
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(current.saved ? '저장을 취소했어요' : '저장했어요')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 300, child: _buildGallery(current)),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                current.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(current.description ?? '', style: const TextStyle(fontSize: 16, height: 1.4)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                '${current.createdAt.toLocal()} • ❤️ ${current.likeCount} • 💬 ${current.commentCount}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),

            // 좋아요(데모)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey),
                    onPressed: () => setState(() => isLiked = !isLiked),
                  ),
                  const Text('좋아요'),
                ],
              ),
            ),

            // 댓글 리스트(데모)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: comments.map((c) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('💬 $c'),
                )).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // 댓글 입력(데모)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: '댓글을 입력하세요',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final t = commentController.text.trim();
                      if (t.isNotEmpty) {
                        setState(() {
                          comments.add(t);
                          commentController.clear();
                        });
                      }
                    },
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
        ? Image.network(src, fit: BoxFit.contain, cacheWidth: 1200, filterQuality: FilterQuality.low,
        errorBuilder: (_, __, ___) =>
        const Center(child: Icon(Icons.broken_image, size: 36, color: Colors.black26)))
        : Image.asset(src, fit: BoxFit.contain, cacheWidth: 1200, filterQuality: FilterQuality.low,
        errorBuilder: (_, __, ___) =>
        const Center(child: Icon(Icons.broken_image, size: 36, color: Colors.black26)));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: img),
    );
  }
}
