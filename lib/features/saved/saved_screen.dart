import 'package:flutter/material.dart';
import 'package:omakase_app/features/models/post.dart';
import 'package:omakase_app/router/app_router.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final List<String> _saved = List.generate(
    18, (i) => 'https://picsum.photos/seed/saved_$i/900/900',
  ); // TODO: API 연동 시 교체

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF111111);
    final isEmpty = _saved.isEmpty;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Saved',
          style: TextStyle(
            color: black,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: isEmpty
          ? const _EmptyState()
          : LayoutBuilder(
              builder: (context, c) {
                final cross = c.maxWidth >= 400 ? 3 : 2;
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cross,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _saved.length,
                  itemBuilder: (_, i) {
                    final post = Post(
                      id: i,
                      title: 'Saved Post $i',
                      imageUrl: _saved[i],
                      createdAt: DateTime.now(),
                      likeCount: i * 5,
                      commentCount: i,
                      images: [_saved[i]],
                      description: 'This is the description for saved post $i',
                      saved: true,
                    );
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.post, arguments: post);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(_saved[i], fit: BoxFit.cover),
                            // 오버레이 아이콘(보기용)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(255, 255, 255, 0.9),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: const Color(0xFFEAEAEA)),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(Icons.bookmark, size: 18, color: black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    const black54 = Color(0x8A000000);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.bookmark_border, size: 48, color: black54),
            SizedBox(height: 12),
            Text('아직 저장한 게시물이 없어요', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Text('마음에 드는 스타일을 저장해 보세요', style: TextStyle(color: black54)),
          ],
        ),
      ),
    );
  }
}
