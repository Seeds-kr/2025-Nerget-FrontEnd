import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../router/app_router.dart';

class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!context.mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout),
              tooltip: '로그아웃',
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                isScrollable: true,
                labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                labelColor: theme.colorScheme.onSurface,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                  insets: const EdgeInsets.symmetric(horizontal: 18),
                ),
                tabs: const [
                  Tab(text: 'Following'),
                  Tab(text: 'For you'),
                  Tab(text: 'Favorites'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _FeedMasonryGrid(),
            _FeedMasonryGrid(),
            _FeedMasonryGrid(),
          ],
        ),
      ),
    );
  }
}

class _FeedMasonryGrid extends StatelessWidget {
  const _FeedMasonryGrid();

  List<String> _buildImagePaths() {
    return List<String>.generate(20, (index) => 'assets/feed_style${index + 1}.jpg');
  }

  @override
  Widget build(BuildContext context) {
    final images = _buildImagePaths();
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 480 ? 4 : 3;
    final aspectRatios = <double>[0.72, 0.85, 1.10, 0.95, 1.25];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: MasonryGridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final path = images[index];
          final ratio = aspectRatios[index % aspectRatios.length];
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: ratio,
              child: Image.asset(
                path,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
