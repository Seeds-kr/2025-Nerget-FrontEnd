class Post {
  final int id;
  final String title;
  final String? imageUrl;        // 리스트 썸네일
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final bool saved;

  // 상세용
  final String? description;
  final List<String> images;

  // ★ 추가: 내가 작성한 글인지
  final bool isMine;

  const Post({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    this.saved = false,
    this.description,
    this.images = const [],
    this.isMine = false, // 기본은 내 글 아님
  });

  Post copyWith({
    int? id,
    String? title,
    String? imageUrl,
    DateTime? createdAt,
    int? likeCount,
    int? commentCount,
    bool? saved,
    String? description,
    List<String>? images,
    bool? isMine,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      saved: saved ?? this.saved,
      description: description ?? this.description,
      images: images ?? this.images,
      isMine: isMine ?? this.isMine,
    );
  }
}


