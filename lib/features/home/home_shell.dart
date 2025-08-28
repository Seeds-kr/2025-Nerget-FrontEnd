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
    final divider = Divider(height: 1, thickness: 1, color: Colors.black.withOpacity(0.06));
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          divider,
          NavigationBar(
            backgroundColor: Colors.white,
            indicatorColor: Colors.transparent,
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), label: 'home'),
              NavigationDestination(icon: Icon(Icons.people_outline), label: 'community'),
              NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'upload'),
              NavigationDestination(icon: Icon(Icons.bookmark_outline), label: 'saved'),
              NavigationDestination(icon: Icon(Icons.person_outline), label: 'mypage'),
            ],
          ),
        ],
      ),
    );
  }
}
