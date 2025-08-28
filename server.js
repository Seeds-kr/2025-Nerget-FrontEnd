// C:\mock-backend\server.js
const jsonServer = require('json-server');
const path = require('path');
const server = jsonServer.create();
const router = jsonServer.router(path.join(__dirname, 'db.json'));
const middlewares = jsonServer.defaults();

server.use(middlewares);
server.use(jsonServer.bodyParser);

// 인위적 지연(네트워크 느낌)
server.use((req, res, next) => {
  setTimeout(next, 300);
});

// 라우트 매핑
server.use(jsonServer.rewriter(require('./routes.json')));

// Google 로그인 목 (POST /api/auth/google)
server.post('/auth/google', (req, res) => {
  // 실서비스에선 idToken을 검증. 여기선 단순 분기만.
  const { idToken, email } = req.body || {};
  if (!idToken) {
    return res.status(400).json({ message: 'idToken required' });
  }

  // 규칙: email이 old@user.com이면 기존회원, 아니면 신규회원
  const isOld = email === 'old@user.com';

  if (isOld) {
    return res.json({
      isNewUser: false,
      accessToken: 'mock_access_token_existing',
      mbti: 'INTJ'
    });
  }
  return res.json({
    isNewUser: true,
    accessToken: 'mock_access_token_new',
    mbti: null
  });
});

// 스타일 분석 목 (POST /api/style/analyze)
server.post('/style/analyze', (req, res) => {
  const { images } = req.body || {};
  if (!Array.isArray(images) || images.length === 0) {
    return res.status(400).json({ message: 'images required' });
  }
  // 간단한 분석 결과
  return res.json({
    styleTags: ['minimal', 'street'],
    confidence: 0.88
  });
});

// 스와이프 목 (POST /api/style/swipe)
server.post('/swipes', (req, res) => {
  const { itemId, liked } = req.body || {};
  if (!itemId || typeof liked !== 'boolean') {
    return res.status(400).json({ message: 'itemId & liked required' });
  }
  return res.status(201).json({ id: Date.now(), itemId, liked });
});

// 기본 라우터
server.use(router);

const PORT = process.env.PORT || 8080;
server.listen(PORT, () => {
  console.log(`Mock API on http://localhost:${PORT}`);
});
  