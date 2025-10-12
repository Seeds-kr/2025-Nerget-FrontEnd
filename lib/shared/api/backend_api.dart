import 'package:http/http.dart' as http;
import 'api_client.dart';

class BackendApi {
  final ApiClient _api = ApiClient();

  // style (이미 존재하는 StyleApi와 중복되지 않게 필요 시 통합)
  // multipart returns StreamedResponse from ApiClient
  Future<http.StreamedResponse> postStyleAnalyzeMultipart(
    List<http.MultipartFile> files,
  ) {
    return _api.multipart('/api/style/analyze', files);
  }

  Future<http.Response> postStyleAnalyzeSkip() =>
      _api.post('/api/style/analyze/skip');
  Future<http.Response> getStyleMbti() => _api.get('/api/style/mbti');
  Future<http.Response> getStyleRecommend() => _api.get('/api/style/recommend');
  Future<http.Response> getStyleTypes() => _api.get('/api/style/types');
  Future<http.Response> getStyleTypeById(String id) =>
      _api.get('/api/style/types/$id');

  // posts / community
  Future<http.Response> createPost(Map<String, dynamic> body) =>
      _api.post('/api/posts', body: body);
  Future<http.Response> listPosts() => _api.get('/api/posts');
  Future<http.Response> getPost(String id) => _api.get('/api/posts/$id');
  Future<http.Response> likePost(String id) => _api.post('/api/posts/$id/like');
  Future<http.Response> bookmarkPost(String id) =>
      _api.post('/api/posts/$id/bookmark');

  // comments
  Future<http.Response> postComment(String postId, Map<String, dynamic> body) =>
      _api.post('/api/posts/$postId/comments', body: body);
  Future<http.Response> listComments(String postId) =>
      _api.get('/api/posts/$postId/comments');

  // mypage
  Future<http.Response> getMyPosts() => _api.get('/api/mypage/posts');
  Future<http.Response> getMyComments() => _api.get('/api/mypage/comments');
  Future<http.Response> getMyLikes() => _api.get('/api/mypage/likes');
  // 서버가 PUT/DELETE 지원하면 ApiClient에 해당 메서드 추가 권장
  Future<http.Response> updateMyPost(String id, Map<String, dynamic> body) =>
      _api.put('/api/posts/$id', body: body); // uses PUT
  Future<http.Response> deleteMyPost(String id) =>
      _api.delete('/api/posts/$id');

  // ai
  Future<http.Response> aiAnalyzeUploaded(Map<String, dynamic> body) =>
      _api.post('/api/ai/analyze-uploaded', body: body);
  Future<http.Response> aiAnalyzeSwipes(Map<String, dynamic> body) =>
      _api.post('/api/ai/analyze-swipes', body: body);
}
