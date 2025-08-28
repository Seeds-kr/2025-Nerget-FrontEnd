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
      bottomNavigationBar: NavigationBarTheme(
        data: const NavigationBarThemeData(
          height: 64,
          indicatorColor: Colors.transparent, // 인디케이터 숨김 (이미지 스타일 유사)
          labelTextStyle: MaterialStatePropertyAll(
            TextStyle(
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          elevation: 8,
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
            NavigationDestination(
              icon: Badge(
                smallSize: 6,
                backgroundColor: Colors.red,
                child: Icon(Icons.home_outlined),
              ),
              selectedIcon: Badge(
                smallSize: 6,
                backgroundColor: Colors.red,
                child: Icon(Icons.home),
              ),
              label: 'HOME',
            ),
            NavigationDestination(
              icon: Badge(
                smallSize: 6,
                backgroundColor: Colors.red,
                child: Icon(Icons.people_outline),
              ),
              selectedIcon: Badge(
                smallSize: 6,
                backgroundColor: Colors.red,
                child: Icon(Icons.people),
              ),
              label: 'COMMUNITY',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'UPLOAD',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_outline),
              selectedIcon: Icon(Icons.bookmark),
              label: 'SAVED',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'MY',
            ),
          ],
        ),
      ),
    );
  }
}
