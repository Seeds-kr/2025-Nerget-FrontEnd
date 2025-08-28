import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  // 프로필/통계
  final Map<String, dynamic> profile = {
    'name': 'helena',
    'username': '@helena',
    'bio': 'Hi! I’m helena😉\nWelcome to my page.',
    'followers': 57,
    'following': 57,
  };

  // 샘플 게시물(assets 등록 필요)
  final List<String> posts = [
    'assets/style1.jpg',
    'assets/style2.jpg',
    'assets/style3.jpg',
    'assets/style4.jpg',
    'assets/style5.jpg',
    'assets/style6.jpg',
    'assets/style7.jpg',
    'assets/style8.jpg',
    'assets/style9.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    // Posts 개수는 리스트 길이로 계산
    final int postCount = posts.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 설정 페이지로 이동
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildHeader(),
          const SizedBox(height: 12),
          _buildStats(postCount),
          const SizedBox(height: 8),
          _buildBio(),
          const SizedBox(height: 8),
          const Divider(height: 1),
          // 게시물 영역
          Expanded(child: postCount == 0 ? _buildEmpty() : _buildGrid()),
        ],
      ),
      // ❌ BottomNavigationBar 제거 (상위 Scaffold에서만 관리)
    );
  }

  // ───────────────── Header: 아바타 + 이름/아이디
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage('assets/style1.jpg'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                profile['username'],
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────── 통계: Posts / Followers / Following
  Widget _buildStats(int postsCount) {
    Widget item(String label, int value) => Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          item('Posts', postsCount),
          item('Followers', profile['followers'] as int),
          item('Following', profile['following'] as int),
        ],
      ),
    );
  }

  // ───────────────── Bio
  Widget _buildBio() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        profile['bio'],
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  // ───────────────── 게시물 없음
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.circle_outlined, size: 96),
          SizedBox(height: 12),
          Text('No Post', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // ───────────────── 그리드(3열)
  Widget _buildGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: posts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        return Image.asset(posts[index], fit: BoxFit.cover);
      },
    );
  }
}
