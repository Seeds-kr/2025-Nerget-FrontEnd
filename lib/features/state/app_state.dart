// lib/state/app_state.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:omakase_app/features/models/post.dart';

class AppState extends ChangeNotifier {
  // 전역 포스트 리스트
  final List<Post> _posts = [];
  int _nextId = 1000;

  // 조회용
  List<Post> get posts => List.unmodifiable(_posts);
  List<Post> get savedPosts => _posts.where((p) => p.saved).toList();
  List<Post> get myPosts => _posts.where((p) => p.isMine).toList();

  // 더미 데이터 채우기 (개발용)
  void seedDummy() {
    final rnd = Random(42);
    _posts.clear();
    for (var i = 0; i < 30; i++) {
      final gallery = [
        'https://picsum.photos/seed/p${i}_1/1080/720',
        'https://picsum.photos/seed/p${i}_2/1080/720',
        'https://picsum.photos/seed/p${i}_3/1080/720',
      ];
      _posts.add(
        Post(
          id: i + 1,
          title: 'Post #${i + 1} — 더미 타이틀',
          imageUrl: i % 3 == 0
              ? 'https://picsum.photos/seed/p$i/600/400'
              : null,
          createdAt: DateTime.now().subtract(Duration(hours: i * 6)),
          likeCount: rnd.nextInt(120),
          commentCount: rnd.nextInt(40),
          saved: i % 5 == 0,
          description: '이건 Post #${i + 1}의 상세 설명(더미 텍스트)입니다.',
          images: i.isEven ? gallery.take(2).toList() : const [],
          isMine: i % 7 == 0,
        ),
      );
    }
    _nextId = 1000;
    notifyListeners();
  }

  // 저장 토글
  void toggleSave(int postId) {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final p = _posts[idx];
    _posts[idx] = p.copyWith(saved: !p.saved);
    notifyListeners();
  }

  // 좋아요 토글
  void toggleLike(int postId) {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final p = _posts[idx];
    _posts[idx] = p.copyWith(
      liked: !p.liked,
      likeCount: p.liked ? p.likeCount - 1 : p.likeCount + 1,
    );
    notifyListeners();
  }

  // 댓글 추가
  void addComment(int postId, String comment) {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final p = _posts[idx];
    _posts[idx] = p.copyWith(
      comments: [comment, ...p.comments],
      commentCount: p.commentCount + 1,
    );
    notifyListeners();
  }


  // 게시글 올리기(내 글)
  void addPost({
    required String title,
    String? description,
    String? imageUrl,
    List<String> images = const [],
  }) {
    final id = _nextId++;
    final thumb = imageUrl ?? (images.isNotEmpty ? images.first : null);
    _posts.insert(
      0,
      Post(
        id: id,
        title: title,
        imageUrl: thumb,
        createdAt: DateTime.now(),
        likeCount: 0,
        commentCount: 0,
        saved: false,
        description: description,
        images: images,
        isMine: true,
      ),
    );
    notifyListeners();
  }

  /// 🔸 커뮤니티 더미 등 "외부"에서 들어온 글을 전역 리스트에 등록
  /// (상세에서 북마크가 실제로 동작하려면 전역에 있어야 함)
  int ensureExternalPost({
    required String title,
    String? description,
    String? imageUrl,
    List<String> images = const [],
  }) {
    final id = _nextId++; // 고유 id 발급
    final thumb = imageUrl ?? (images.isNotEmpty ? images.first : null);
    _posts.insert(
      0,
      Post(
        id: id,
        title: title,
        imageUrl: thumb,
        createdAt: DateTime.now(),
        likeCount: 0,
        commentCount: 0,
        saved: false,
        description: description,
        images: images,
        isMine: false,
      ),
    );
    notifyListeners();
    return id;
  }

  /// 커뮤니티 샘플 에셋으로 초기 시드 (이미 데이터가 있으면 스킵)
  void seedCommunityAssetsIfEmpty() {
    if (_posts.isNotEmpty) return;
    final samples = <Map<String, dynamic>>[
      {
        'title': 'INFP',
        'images': ['assets/style1.jpg'],
        'description': 'INFP',
      },
      {
        'title': 'ENTP',
        'images': ['assets/style2.jpg'],
        'description': 'ENTP',
      },
      {
        'title': 'ESTJ',
        'images': ['assets/style3.jpg', 'assets/style4.jpg'],
        'description': 'ESTJ',
      },
      {
        'title': 'ISFJ',
        'images': ['assets/style5.jpg'],
        'description': 'ISFJ',
      },
      {
        'title': 'INTJ',
        'images': ['assets/style6.jpg'],
        'description': 'INTJ',
      },
    ];
    for (final s in samples) {
      ensureExternalPost(
        title: s['title'] as String,
        description: s['description'] as String?,
        images: (s['images'] as List).cast<String>(),
      );
    }
  }
}

// 전역 상태 공유용 InheritedNotifier
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }

  @override
  bool updateShouldNotify(covariant InheritedNotifier<AppState> oldWidget) {
    return oldWidget.notifier != notifier;
  }
}

// context.app 확장자
extension AppStateX on BuildContext {
  AppState get app => AppStateScope.of(this);
}
