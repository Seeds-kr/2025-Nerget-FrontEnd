import 'package:flutter/material.dart';
import '../home/home_feed_screen.dart';
import '../community/community_screen.dart';
import '../upload/upload_style_screen.dart';
import '../saved/saved_screen.dart';
import '../mypage/mypage_screen.dart';

class HomeShell extends StatefulWidget {
  final int initialIndex;
  const HomeShell({super.key, this.initialIndex = 0});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index = widget.initialIndex;

  final _tabs = const <Widget>[
    HomeFeedScreen(), // 피드
    CommunityPage(), // 커뮤니티
    UploadStyleScreen(), // 업로드(탭에서 바로 업로드)
    SavedScreen(), // 저장됨
    MyPage(), // 마이페이지
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
          // URL 동기화
          switch (i) {
            case 0:
              Navigator.of(context).pushReplacementNamed('/feed');
              break;
            case 1:
              Navigator.of(context).pushReplacementNamed('/community');
              break;
            case 2:
              Navigator.of(context).pushReplacementNamed('/upload');
              break;
            case 3:
              Navigator.of(context).pushReplacementNamed('/saved');
              break;
            case 4:
              Navigator.of(context).pushReplacementNamed('/mypage');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: '홈'),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: '커뮤니티',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: '업로드',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            label: '저장',
          ),
          NavigationDestination(icon: Icon(Icons.person_outline), label: '마이'),
        ],
      ),
    );
  }
}
