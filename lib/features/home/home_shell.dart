import 'package:flutter/material.dart';
import 'package:omakase_app/router/app_router.dart';
import '../home/home_feed_screen.dart';
import '../community/community_screen.dart';
import '../saved/saved_screen.dart';
import '../mypage/mypage_screen.dart';

class HomeShell extends StatefulWidget {
  final int initialIndex;
  final int feedInitialTabIndex;

  const HomeShell({
    super.key,
    this.initialIndex = 0,
    this.feedInitialTabIndex = 0,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index = widget.initialIndex;

  // Upload screen is removed from the list of tabs
  final List<Widget> _tabs = <Widget>[
    HomeFeedScreen(initialTabIndex: 0), // index 0
    const CommunityPage(), // index 1
    const SavedScreen(), // index 2
    const MyPage(), // index 3
  ];

  void _onItemTapped(int i) {
    if (_index == i) return;
    setState(() => _index = i);
  }

  Widget _buildNavItem(IconData unselectedIcon, IconData selectedIcon, String label, int index) {
    final isSelected = _index == index;
    final color = isSelected ? Colors.black : Colors.grey.shade600;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.translucent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? selectedIcon : unselectedIcon, color: color),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      floatingActionButton: FloatingActionButton(
        // Navigate to the Upload screen
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.upload);
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        elevation: 2.0,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Colors.white,
        elevation: 8.0,
        surfaceTintColor: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
            _buildNavItem(Icons.people_outline, Icons.people, 'Community', 1),
            const Expanded(child: SizedBox()), // The space for the notch
            // Adjust indices for Saved and MyPage
            _buildNavItem(Icons.bookmark_outline, Icons.bookmark, 'Saved', 2),
            _buildNavItem(Icons.person_outline, Icons.person, 'MyPage', 3),
          ],
        ),
      ),
    );
  }
}
