import 'package:flutter/material.dart';
import '../state/app_state.dart';     // ★ 추가: 전역 상태 접근 (context.app)
import '../models/post.dart';        // ★ 추가: Post 타입
import 'post_detail_page.dart';      // ★ 추가: 상세 페이지

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  @override
  bool get wantKeepAlive => true; // 탭 전환 시 상태 유지

  // 홈 피드 더미 데이터 (원본 유지)
  final List<ThreadItem> _feed = [
    ThreadItem(
      avatar: 'assets/avatar.png',
      displayName: 'nuget',
      handle: '@nuget',
      text: '메인 홈페이지이구 사진은 최대 4장',
      images: ['assets/infp.jpg'],
      timeAgo: '2h',
      likes: 23,
      comments: 4,
    ),
    ThreadItem(
      avatar: 'assets/avatar.png',
      displayName: 'imnuget',
      handle: '@nuget_dev',
      text: '두 장 테스트',
      images: ['assets/entp.jpg', 'assets/isfj.jpg'],
      timeAgo: '5h',
      likes: 11,
      comments: 2,
    ),
    ThreadItem(
      avatar: 'assets/avatar.png',
      displayName: 'seed',
      handle: '@seed',
      text: '세 장 테스트',
      images: ['assets/estj.jpg', 'assets/intj.jpg', 'assets/estj2.jpg'],
      timeAgo: '1d',
      likes: 58,
      comments: 12,
    ),
    ThreadItem(
      avatar: 'assets/avatar.png',
      displayName: 'nuget team',
      handle: '@team',
      text: '네 장 테스트',
      images: [
        'assets/infp.jpg',
        'assets/entp.jpg',
        'assets/isfj.jpg',
        'assets/intj.jpg'
      ],
      timeAgo: '2d',
      likes: 102,
      comments: 33,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context); // keep-alive 사용 시 반드시 호출
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 400));
          setState(() {});
        },
        child: ListView.separated(
          key: const PageStorageKey('home_feed'),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _feed.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = _feed[index];
            return _ThreadCard(item: item);
          },
        ),
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  final ThreadItem item;
  const _ThreadCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // ★ 홈 카드 탭 → 전역 상태에 등록 후 상세로 이동
      onTap: () {
        final app = context.app;
        final newId = app.ensureExternalPost(
          title: item.text.isNotEmpty ? item.text : item.displayName,
          description: item.text,
          images: item.images, // 에셋 경로도 OK (상세에서 처리)
        );
        final Post post = app.posts.firstWhere((p) => p.id == newId);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
        );
      },
      child: Padding(
        const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(item.avatar),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name / handle / time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.handle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '· ${item.timeAgo}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Text
                  if (item.text.isNotEmpty)
                    Text(
                      item.text,
                      style: const TextStyle(fontSize: 15, height: 1.3),
                    ),
                  // Images (max 4)
                  if (item.images.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _ImageGrid(paths: item.images),
                  ],
                  const SizedBox(height: 8),
                  // Actions
                  Row(
                    children: [
                      _ActionBtn(
                        icon: Icons.favorite_border,
                        label: item.likes.toString(),
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      _ActionBtn(
                        icon: Icons.mode_comment_outlined,
                        label: item.comments.toString(),
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      _ActionBtn(
                        icon: Icons.send_outlined,
                        label: 'Share',
                        onTap: () {},
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () {},
                        splashRadius: 20,
                      ),
                    ],
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

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

/// 이미지 최대 4장까지 보여주는 그리드
class _ImageGrid extends StatelessWidget {
  final List<String> paths;
  const _ImageGrid({required this.paths});

  @override
  Widget build(BuildContext context) {
    final imgs = paths.take(4).toList(); // 최대 4장
    final count = imgs.length;

    if (count == 1) return _one(imgs[0]);
    if (count == 2) return _two(imgs);
    if (count == 3) return _three(imgs);
    return _four(imgs);
  }

  Widget _one(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
          const Center(child: Icon(Icons.broken_image, size: 36, color: Colors.black26)),
        ),
      ),
    );
  }

  Widget _two(List<String> imgs) {
    return Row(
      children: [
        Expanded(
          child: _tile(
            imgs[0],
            const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _tile(
            imgs[1],
            const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _three(List<String> imgs) {
    return Row(
      children: [
        // Left big
        Expanded(
          flex: 2,
          child: _tile(
            imgs[0],
            const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            aspect: 4 / 5,
          ),
        ),
        const SizedBox(width: 6),
        // Right column 2 small
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _tile(
                imgs[1],
                const BorderRadius.only(topRight: Radius.circular(12)),
                aspect: 16 / 10,
              ),
              const SizedBox(height: 6),
              _tile(
                imgs[2],
                const BorderRadius.only(bottomRight: Radius.circular(12)),
                aspect: 16 / 10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _four(List<String> imgs) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _tile(imgs[0], const BorderRadius.only(topLeft: Radius.circular(12)))),
            const SizedBox(width: 6),
            Expanded(child: _tile(imgs[1], const BorderRadius.only(topRight: Radius.circular(12)))),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _tile(imgs[2], const BorderRadius.only(bottomLeft: Radius.circular(12)))),
            const SizedBox(width: 6),
            Expanded(child: _tile(imgs[3], const BorderRadius.only(bottomRight: Radius.circular(12)))),
          ],
        ),
      ],
    );
  }

  Widget _tile(String path, BorderRadius radius, {double aspect = 1}) {
    return ClipRRect(
      borderRadius: radius,
      child: AspectRatio(
        aspectRatio: aspect,
        child: Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
          const Center(child: Icon(Icons.broken_image, size: 36, color: Colors.black26)),
        ),
      ),
    );
  }
}

/// 홈 피드용 간단 모델 (실서비스에선 서버 DTO로 대체)
class ThreadItem {
  final String avatar;
  final String displayName;
  final String handle;
  final String text;
  final List<String> images;
  final String timeAgo;
  final int likes;
  final int comments;

  ThreadItem({
    required this.avatar,
    required this.displayName,
    required this.handle,
    required this.text,
    required this.images,
    required this.timeAgo,
    required this.likes,
    required this.comments,
  });
}
