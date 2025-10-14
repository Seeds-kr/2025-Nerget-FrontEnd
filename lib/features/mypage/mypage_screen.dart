import 'package:flutter/material.dart';
import 'package:omakase_app/features/models/post.dart';
import 'package:omakase_app/router/app_router.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final List<String> _myPosts = List.generate(
    18, (i) => 'https://picsum.photos/seed/me_$i/900/900',
  ); // TODO: API 연동 시 교체

  Widget _buildStatColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF111111);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: const Text('옷마카세', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              centerTitle: true,
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFEAEAEA),
                      child: Icon(Icons.person, size: 40, color: black),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '@otmakase_user',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Finding minimal, clean looks daily.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('프로필 편집 준비 중')));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: black,
                          side: const BorderSide(color: Color(0xFFDDDDDD)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Edit Profile'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn('120', 'Posts'),
                        _buildStatColumn('2.4K', 'Followers'),
                        _buildStatColumn('320', 'Following'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                  ],
                ),
              ),
            ),
          ];
        },
        body: _PostList(items: _myPosts),
      ),
    );
  }
}

class _PostList extends StatelessWidget {
  final List<String> items;
  const _PostList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _Empty();
    }
    return LayoutBuilder(
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
          itemCount: items.length,
          itemBuilder: (_, i) {
            final post = Post(
              id: i,
              title: 'My Post $i',
              imageUrl: items[i],
              createdAt: DateTime.now(),
              likeCount: i * 10,
              commentCount: i * 2,
              images: [items[i]],
              description: 'This is the description for post $i',
            );
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.post, arguments: post);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(items[i], fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200])),
              ),
            );
          },
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    const black54 = Color(0x8A000000);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.image_outlined, size: 48, color: black54),
          SizedBox(height: 8),
          Text('아직 콘텐츠가 없어요', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 4),
          Text('업로드하거나 저장해 보세요', style: TextStyle(color: black54)),
        ],
      ),
    );
  }
}
