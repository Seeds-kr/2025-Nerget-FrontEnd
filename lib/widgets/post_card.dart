import 'package:flutter/material.dart';
import '../models/post.dart';
import '../state/app_state.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const PostCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _thumb(post.imageUrl),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Text(
                post.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [
                  Text('❤️ ${post.likeCount}   💬 ${post.commentCount}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const Spacer(),
                  IconButton(
                    icon: Icon(post.saved ? Icons.bookmark : Icons.bookmark_border),
                    onPressed: () => app.toggleSave(post.id),
                    tooltip: post.saved ? '저장 취소' : '저장',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumb(String? url) {
    if (url == null) {
      return const SizedBox(
        height: 180,
        child: Center(child: Icon(Icons.image, size: 48, color: Colors.black26)),
      );
    }
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        // 네트워크 느려도 프레임 드랍 줄이기용
        errorBuilder: (_, __, ___) =>
        const Center(child: Icon(Icons.broken_image, size: 36, color: Colors.black26)),
      ),
    );
  }
}
