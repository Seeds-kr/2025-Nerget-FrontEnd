import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../router/app_router.dart';
import '../state/app_state.dart';
import '../models/post.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const _FeedList(),
    );
  }
}

class _FeedList extends StatelessWidget {
  const _FeedList();

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final List<Post> items = app.posts;
    if (items.isEmpty) {
      return const Center(child: Text('피드가 비어있어요'));
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: items.length,
      itemBuilder: (_, i) => _PostTile(post: items[i]),
    );
  }
}

class _PostTile extends StatelessWidget {
  final Post post;
  const _PostTile({required this.post});

  @override
  Widget build(BuildContext context) {
    final image = (post.images.isNotEmpty)
        ? post.images.first
        : (post.imageUrl ?? '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(post.title),
          subtitle: Text(post.createdAt.toLocal().toString()),
        ),
        if (image.isNotEmpty)
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Image(
              image: image.startsWith('http')
                  ? NetworkImage(image)
                  : AssetImage(image) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        if ((post.description ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(post.description!),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}
