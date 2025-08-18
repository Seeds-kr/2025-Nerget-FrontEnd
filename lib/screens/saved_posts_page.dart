import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/post_card.dart';

class SavedPostsPage extends StatelessWidget {
  const SavedPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final saved = app.savedPosts;

    return Scaffold(
      appBar: AppBar(title: const Text('저장한 게시글')),
      body: saved.isEmpty
          ? const Center(child: Text('저장한 게시물이 없어요', style: TextStyle(color: Colors.black54)))
          : ListView.builder(
        key: const PageStorageKey('saved_list'),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: saved.length,
        itemBuilder: (_, i) => PostCard(post: saved[i]),
      ),
    );
  }
}

