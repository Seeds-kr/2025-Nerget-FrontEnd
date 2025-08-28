/*import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Community Tab'));
}
*/
import 'package:flutter/material.dart';
import '../state/app_state.dart'; // context.app 확장자 사용
import '../models/post.dart'; // 우리 프로젝트의 Post 모델
import '../home/post_detail_page.dart'; // 상세 페이지

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
    'INFP',
    'ENFP',
    'INFJ',
    'ENFJ',
    'INTP',
    'ENTP',
    'INTJ',
    'ENTJ',
    'ISFP',
    'ESFP',
    'ISFJ',
    'ESFJ',
    'ISTP',
    'ESTP',
    'ISTJ',
    'ESTJ',
  ];

  // 기존 더미는 AppState에 시드됨. 여기서는 전역 posts를 그대로 사용

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final app = context.app;
    final List<Post> source = app.posts;
    final List<Post> filtered = (selectedMbti == null || selectedMbti == '전체')
        ? source
        : source.where((p) => p.title.toUpperCase() == selectedMbti).toList();

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
                        selectedMbti = (mbti == '전체')
                            ? null
                            : (isSelected ? null : mbti);
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
      body: ListView.separated(
        key: const PageStorageKey('community_feed'),
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final post = filtered[index];
          final image = (post.images.isNotEmpty)
              ? post.images.first
              : (post.imageUrl ?? '');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(post.title),
                subtitle: Text(post.createdAt.toLocal().toString()),
              ),
              if (image.isNotEmpty)
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailPage(post: post),
                    ),
                  ),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Image(
                      image: image.startsWith('http')
                          ? NetworkImage(image)
                          : AssetImage(image) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if ((post.description ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(post.description!),
                ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}

/// 화면 내 더미용 타입 (우리 Post와 이름 충돌 방지)
class CommunityPost {
  final List<String> images; // 에셋 경로들
  final String mbti;
  final String description;

  const CommunityPost({
    required this.images,
    required this.mbti,
    required this.description,
  });
}

