import 'package:flutter/material.dart';
import 'package:omakase_app/features/models/post.dart';
import 'package:omakase_app/router/app_router.dart';

/// HomeShell의 홈 피드 화면 (새 디자인 적용)
/// - 상단 "Recommended style" 타이틀 (검색 없음)
/// - 2열(소형)/3열(대형) 1:1 카드, 라운드 12
/// - 무한 스크롤 + 당겨서 새로고침
class HomeFeedScreen extends StatefulWidget {
  final int initialTabIndex; // 기존 시그니처 유지
  const HomeFeedScreen({super.key, this.initialTabIndex = 0});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final _scroll = ScrollController();
  final List<String> _images = [];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _page = 0;
    _images.clear();
    _hasMore = true;
    setState(() {});
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      // TODO: 여기서 AWS/API 연동으로 교체
      await Future.delayed(const Duration(milliseconds: 250));
      final newUrls = List.generate(
        30,
            (i) => 'https://picsum.photos/seed/reco_${_page}_$i/900/900',
      );
      _images.addAll(newUrls);
      _hasMore = newUrls.isNotEmpty;
      _page++;
      if (mounted) setState(() {});
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF111111);
    const divider = Color(0xFFEAEAEA);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: const Text('Recommended style',
            style: TextStyle(color: black, fontWeight: FontWeight.w800)),
      ),
      body: RefreshIndicator(
        color: black,
        onRefresh: _refresh,
        child: LayoutBuilder(
          builder: (context, c) {
            final cross = c.maxWidth >= 400 ? 3 : 2;
            return CustomScrollView(
              controller: _scroll,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cross,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: _images.length,
                    itemBuilder: (_, i) {
                      final post = Post(
                        id: i,
                        title: 'Recommended Post $i',
                        imageUrl: _images[i],
                        createdAt: DateTime.now(),
                        likeCount: i * 3,
                        commentCount: i,
                        images: [_images[i]],
                        description: 'This is a recommended post #$i',
                      );
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.post, arguments: post);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _images[i],
                            fit: BoxFit.cover,
                            frameBuilder: (context, child, frame, wasSync) {
                              if (wasSync || frame != null) return child;
                              return AnimatedOpacity(
                                opacity: frame == null ? 0 : 1,
                                duration: const Duration(milliseconds: 180),
                                child: child,
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFF5F5F5),
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_not_supported, color: black),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: _loading
                      ? const Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : const SizedBox(height: 24),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Divider(height: 1, color: divider),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
