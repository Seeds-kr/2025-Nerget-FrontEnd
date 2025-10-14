import 'package:flutter/material.dart';
import 'package:omakase_app/features/models/post.dart';
import 'package:omakase_app/router/app_router.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final ScrollController _scroll = ScrollController();
  final List<Map<String, dynamic>> _posts = [];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 0;

  String? _selectedMbti;

  final List<String> _mbtiList = [
    'INTJ','INTP','ENTJ','ENTP','INFJ','INFP','ENFJ','ENFP',
    'ISTJ','ISFJ','ESTJ','ESFJ','ISTP','ISFP','ESTP','ESFP',
  ];

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
    _posts.clear();
    _hasMore = true;
    setState(() {});
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final newPosts = List.generate(10, (i) {
        final idx = _page * 10 + i;
        return {
          'id': idx,
          'mbti': _mbtiList[idx % _mbtiList.length],
          'user': 'User_$idx',
          'img': 'https://picsum.photos/seed/post_$idx/800/800',
          'caption': '오늘의 스타일 ✨ #OOTD #${_mbtiList[idx % _mbtiList.length]}',
          'likes': (idx * 13) % 97,
          'comments': (idx * 7) % 15,
        };
      });

      _posts.addAll(newPosts);
      _hasMore = newPosts.isNotEmpty;
      _page++;
      if (mounted) setState(() {});
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredPosts {
    if (_selectedMbti == null) return _posts;
    return _posts.where((p) => p['mbti'] == _selectedMbti).toList();
  }

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF111111);
    const divider = Color(0xFFEAEAEA);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Community',
          style: TextStyle(
            color: black,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: black,
        child: CustomScrollView(
          controller: _scroll,
          slivers: [
            // MBTI 필터 헤더
            SliverToBoxAdapter(
              child: SizedBox(
                height: 96,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: _mbtiList.length,
                  itemBuilder: (context, i) {
                    final type = _mbtiList[i];
                    final selected = _selectedMbti == type;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMbti = selected ? null : type;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected ? Colors.black : const Color(0xFFE0E0E0),
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: selected ? Colors.black : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 게시물 피드
            SliverList.builder(
              itemCount: _filteredPosts.length,
              itemBuilder: (context, i) {
                final postData = _filteredPosts[i];
                final post = Post(
                  id: postData['id'],
                  title: postData['user'],
                  imageUrl: postData['img'],
                  createdAt: DateTime.now(),
                  likeCount: postData['likes'],
                  commentCount: postData['comments'],
                  description: postData['caption'],
                  images: [postData['img']],
                );

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.post, arguments: post);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 유저 영역
                      ListTile(
                        leading: const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFFEEEEEE),
                          child: Icon(Icons.person, color: black),
                        ),
                        title: Text(
                          post.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(postData['mbti'], style: const TextStyle(fontSize: 12)),
                        dense: true,
                      ),

                      // 이미지
                      AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          post.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFF5F5F5),
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported, color: black),
                          ),
                        ),
                      ),

                      // 액션버튼
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite_border),
                              onPressed: () {},
                              splashRadius: 20,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chat_bubble_outline),
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.post, arguments: post);
                              },
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ),

                      // 캡션
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          post.description ?? '',
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: divider),
                    ],
                  ),
                );
              },
            ),

            // 로딩 인디케이터
            SliverToBoxAdapter(
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }
}
