// lib/screens/community_page.dart
import 'package:flutter/material.dart';
import '../state/app_state.dart';        // context.app 확장자 사용
import '../models/post.dart';            // 우리 프로젝트의 Post 모델
import 'post_detail_page.dart';          // 상세 페이지

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with AutomaticKeepAliveClientMixin<CommunityPage> {
  @override
  bool get wantKeepAlive => true;

  String? selectedMbti; // null이면 '전체'

  static const List<String> mbtiList = [
    '전체',
    'INFP', 'ENFP', 'INFJ', 'ENFJ',
    'INTP', 'ENTP', 'INTJ', 'ENTJ',
    'ISFP', 'ESFP', 'ISFJ', 'ESFJ',
    'ISTP', 'ESTP', 'ISTJ', 'ESTJ',
  ];

  // 원본 더미 데이터 (에셋 경로 그대로 유지)
  final List<CommunityPost> allPosts = const [
    CommunityPost(images: ['assets/infp.jpg'],                     mbti: 'INFP', description: 'INFP'),
    CommunityPost(images: ['assets/entp.jpg'],                     mbti: 'ENTP', description: 'ENTP'),
    CommunityPost(images: ['assets/estj.jpg', 'assets/estj2.jpg'], mbti: 'ESTJ', description: 'ESTJ'),
    CommunityPost(images: ['assets/isfj.jpg'],                     mbti: 'ISFJ', description: 'ISFJ'),
    CommunityPost(images: ['assets/intj.jpg'],                     mbti: 'INTJ', description: 'INTJ'),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // MBTI 필터링
    final List<CommunityPost> filtered = (selectedMbti == null || selectedMbti == '전체')
        ? allPosts
        : allPosts.where((p) => p.mbti == selectedMbti).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: mbtiList.length,
              itemBuilder: (context, index) {
                final mbti = mbtiList[index];
                final bool isSelected = (selectedMbti ?? '전체') == mbti;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(
                      mbti,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        selectedMbti =
                        (mbti == '전체') ? null : (isSelected ? null : mbti);
                      });
                    },
                    selectedColor: Colors.blueAccent,
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.blueAccent
                            : (Colors.grey[300]!),
                      ),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: GridView.builder(
        key: const PageStorageKey('community_grid'),
        padding: const EdgeInsets.all(8),
        itemCount: filtered.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,          // 3열
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final cp = filtered[index];

          return GestureDetector(
            onTap: () {
              // ✅ 전역 상태(AppState)에 먼저 등록 → 저장/해제 등 상태 연동 가능
              final app = context.app;
              final newId = app.ensureExternalPost(
                title: cp.mbti,
                description: cp.description,
                images: cp.images, // 에셋 경로 그대로 넘겨도 상세에서 처리됨
              );
              final Post post = app.posts.firstWhere((p) => p.id == newId);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
              );
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    cp.images.first,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0x11000000),
                      child: Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
                if (cp.images.length > 1)
                  const Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(Icons.collections, size: 18, color: Colors.white),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 화면 내 더미용 타입 (우리 Post와 이름 충돌 방지)
class CommunityPost {
  final List<String> images;   // 에셋 경로들
  final String mbti;
  final String description;

  const CommunityPost({
    required this.images,
    required this.mbti,
    required this.description,
  });
}
