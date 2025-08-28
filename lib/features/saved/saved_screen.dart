import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/post.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final List<Post> items = app.savedPosts;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Saved Posts',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 2),
            Text(
              '모든 저장',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Colors.black.withOpacity(0.06)),
        ),
      ),
      body: items.isEmpty
          ? const Center(child: Text('저장한 게시물이 없습니다'))
          : Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: LayoutBuilder(
                builder: (context, c) {
                  final crossAxisCount = c.maxWidth >= 480 ? 3 : 2;
                  final aspectRatios = <double>[0.9, 1.1, 0.75, 1.25, 0.95];
                  return MasonryGridView.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final p = items[index];
                      final path = (p.images.isNotEmpty)
                          ? p.images.first
                          : (p.imageUrl ?? '');
                      final ratio = aspectRatios[index % aspectRatios.length];
                      if (path.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final radius = BorderRadius.circular(16);
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black.withOpacity(0.08)),
                          borderRadius: radius,
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: radius,
                          child: AspectRatio(
                            aspectRatio: ratio,
                            child: Image(
                              image: path.startsWith('http')
                                  ? NetworkImage(path)
                                  : AssetImage(path) as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
