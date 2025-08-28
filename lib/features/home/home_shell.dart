import 'package:flutter/material.dart';
import '../home/home_feed_screen.dart';
import '../community/community_screen.dart';
import '../upload/upload_style_screen.dart';
import '../saved/saved_screen.dart';
import '../mypage/mypage_screen.dart';

class HomeShell extends StatefulWidget {
  final int initialIndex;
  final int feedInitialTabIndex;
  const HomeShell({super.key, this.initialIndex = 0, this.feedInitialTabIndex = 0});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index = widget.initialIndex;

  List<Widget> get _tabs => <Widget>[
    HomeFeedScreen(initialTabIndex: widget.feedInitialTabIndex),
    const CommunityPage(),
    const UploadStyleScreen(),
    const SavedScreen(),
    const MyPage(),
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
            onDestinationSelected: (i) {
              setState(() => _index = i);
              // URL 동기화 (웹에서 주소 해시 변경)
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
