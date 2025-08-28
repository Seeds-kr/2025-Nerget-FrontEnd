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
        title: const SizedBox.shrink(),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (done) {
            final double maxW = constraints.maxWidth.clamp(0, 560);
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(width: maxW, child: const _SwipeResultView()),
            );
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
                  ],
                ),
              ),
            ),
          );
        },
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

class _SwipeResultView extends StatelessWidget {
  const _SwipeResultView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Column(
              children: const [
                Icon(Icons.auto_awesome, size: 40),
                SizedBox(height: 12),
                Text('스타일 소개팅 완료!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text('당신만의 패션 MBTI가 분석되었습니다',
                    style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),

          // MBTI 카드
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.08)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              children: const [
                Text('당신의 패션 MBTI는',
                    style: TextStyle(color: Colors.black54)),
                SizedBox(height: 8),
                Text('INTJ',
                    style: TextStyle(
                        fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 2)),
                SizedBox(height: 8),
                Text('컬러풀 미니멀리스트',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 섹션 타이틀
          Row(
            children: const [
              Icon(Icons.favorite_border, size: 18),
              SizedBox(width: 6),
              Text('스타일 특징', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '컬러 포인트를 활용한 미니멀한 스타일링을 선호하는 당신! 기본적으로는 심플하고 깔끔한 옷차림을 좋아하지만, 포인트가 되는 컬러나 액세서리로 개성을 표현하는 것을 즐깁니다. 개구쟁이 같은 분위기를 선호하면서도 다양한 스타일에 도전하는 것을 두려워하지 않는 유연한 패션 감각을 가지고 있어요.',
            style: TextStyle(height: 1.45),
          ),

          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _Tag('#컬러포인트'),
              _Tag('#미니멀'),
              _Tag('#캐주얼'),
              _Tag('#다양성'),
            ],
          ),

          const SizedBox(height: 20),

          // 버튼들
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const HomeShell(initialIndex: 0),
                    settings: const RouteSettings(name: AppRoutes.feed),
                  ),
                );
              },
              child: const Text('나만의 스타일 추천받기',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.black.withOpacity(0.2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('공유하기 기능은 준비 중입니다.')),
                );
              },
              child: const Text('결과 공유하기',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
