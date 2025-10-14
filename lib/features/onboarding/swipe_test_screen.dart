import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:omakase_app/router/app_router.dart';
import 'package:omakase_app/features/home/home_shell.dart';
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
      // 전송 실패 시 UI 알림 없이 무시 (조용히 실패 처리)
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
        title: const SizedBox.shrink(),
        actions: [
          TextButton(
            onPressed: done
                ? null
                : () => Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRoutes.feed),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            child: const Text('Skip'),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (done) {
            // 결과 페이지로 이동하기 전의 로딩 상태
            return const Center(child: CircularProgressIndicator());
          }
          final double maxW = constraints.maxWidth.clamp(0, 560);
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: maxW,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Style Match',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Dismissible(
                        key: ValueKey(_items[_index]),
                        direction: DismissDirection.horizontal,
                        // ✅ 1) 즉시 UI에서 제거하고
                        onDismissed: (dir) {
                          final liked = dir == DismissDirection.startToEnd;
                          final currentItem = _items[_index];

                          setState(() {
                            _index++; // 트리에서 즉시 제거
                            if (_index >= _items.length) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  AppRoutes.mbtiResult,
                                  (route) => false,
                                  arguments: 'INFP', // TODO: 실제 MBTI 결과로 교체
                                );
                              });
                            }
                          });

                          // 다음 장 미리 로드
                          _precacheNext();

                          // ✅ 2) 전송은 백그라운드로 (await 하지 않음)
                          _sendSwipe(currentItem, liked);
                        },
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          color: const Color(0x1A22C55E), // 초록색(20% 불투명)
                          child: const Icon(
                            Icons.favorite,
                            size: 48,
                            color: Color(0xFF22C55E), // 초록
                          ),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          color: const Color(0x1AE11D48), // 빨강(20% 불투명)
                          child: const Icon(
                            Icons.close,
                            size: 48,
                            color: Color(0xFFE11D48), // 빨강
                          ),
                        ),
                        child: Center(
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
                                        color: Color(
                                          0x00000000,
                                        ), // 스피너 가리고 싶으면 투명
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: done
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _sending
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
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black),
                          minimumSize: const Size.fromHeight(52),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _sending
                            ? null
                            : () {
                                final currentItem = _items[_index];
                                setState(() => _index++);
                                _precacheNext();
                                _sendSwipe(currentItem, true);
                              },
                        icon: const Icon(Icons.favorite),
                        label: const Text('좋아요'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
