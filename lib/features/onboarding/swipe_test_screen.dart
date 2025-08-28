import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:omakase_app/router/app_router.dart';
import 'package:omakase_app/shared/api/env.dart' as appenv;

class SwipeTestScreen extends StatefulWidget {
  const SwipeTestScreen({super.key});

  @override
  State<SwipeTestScreen> createState() => _SwipeTestScreenState();
}

class _SwipeTestScreenState extends State<SwipeTestScreen> {
  final List<String> _items = [
    'assets/style1.jpg',
    'assets/style2.jpg',
    'assets/style3.jpg',
    'assets/style4.jpg',
    'assets/style5.jpg',
    'assets/style6.jpg',
    'assets/style7.jpg',
    'assets/style8.jpg',
  ];

  int _index = 0;
  bool _sending = false;

  late final Dio _mockDio = Dio(
    BaseOptions(
      baseUrl: appenv.Env.apiBaseUrl(),
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );

  bool _isAsset(String path) => path.startsWith('assets/');

  ImageProvider _provider(String path) =>
      _isAsset(path) ? AssetImage(path) : NetworkImage(path);

  Widget _buildImage(String path) =>
      Image(image: _provider(path), fit: BoxFit.cover);

  Future<void> _precacheNext() async {
    if (!mounted) return;
    final next = _index + 1;
    if (next < _items.length) {
      try {
        await precacheImage(_provider(_items[next]), context);
      } catch (_) {}
    }
  }

  /// 서버로 좋아요/싫어요 전송 (UI는 이미 넘어간 뒤에 보냄)
  Future<void> _sendSwipe(String itemId, bool liked) async {
    setState(() => _sending = true);
    try {
      if (appenv.Env.useMock) {
        await _mockDio.post(
          '/api/style/swipe',
          data: {'itemId': itemId, 'liked': liked},
          options: Options(contentType: Headers.jsonContentType),
        );
      } else {
        // await StyleApi().sendSwipe(itemId: itemId, liked: liked);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('전송 실패(오프라인 또는 서버 오류)')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // 첫 장 다음 거 미리 로드
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheNext());
  }

  @override
  Widget build(BuildContext context) {
    final done = _index >= _items.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('스타일 스와이프'),
        actions: [
          TextButton(
            onPressed:
                done
                    ? null
                    : () => Navigator.of(
                      context,
                    ).pushReplacementNamed(AppRoutes.feed),
            child: const Text('건너뛰기'),
          ),
        ],
      ),
      body: Center(
        child:
            done
                ? const Text('추천 완료!')
                : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Dismissible(
                    key: ValueKey(_items[_index]),
                    direction: DismissDirection.horizontal,
                    // ✅ 1) 즉시 UI에서 제거하고
                    onDismissed: (dir) {
                      final liked = dir == DismissDirection.startToEnd;
                      final currentItem = _items[_index];

                      setState(() {
                        _index++; // 트리에서 즉시 제거
                      });

                      // 다음 장 미리 로드
                      _precacheNext();

                      // ✅ 2) 전송은 백그라운드로 (await 하지 않음)
                      _sendSwipe(currentItem, liked);
                    },
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: const Icon(Icons.favorite, size: 48),
                    ),
                    secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: const Icon(Icons.close, size: 48),
                    ),
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildImage(_items[_index]),
                            if (_sending)
                              const IgnorePointer(
                                ignoring: true,
                                child: ColoredBox(
                                  color: Color(0x00000000), // 스피너 가리고 싶으면 투명
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
      ),
      bottomNavigationBar:
          done
              ? null
              : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              _sending
                                  ? null
                                  : () {
                                    // 버튼로도 동일 로직 재사용
                                    final currentItem = _items[_index];
                                    setState(() => _index++);
                                    _precacheNext();
                                    _sendSwipe(currentItem, false);
                                  },
                          icon: const Icon(Icons.close),
                          label: const Text('싫어요'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              _sending
                                  ? null
                                  : () {
                                    final currentItem = _items[_index];
                                    setState(() => _index++);
                                    _precacheNext();
                                    _sendSwipe(currentItem, true);
                                  },
                          icon: const Icon(Icons.favorite),
                          label: const Text('좋아요'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
