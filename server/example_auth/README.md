# Example Auth Server

This is a minimal Express example that verifies Google id_tokens (using google-auth-library)
and issues a simple JWT access token. It's intended for local development and testing with the
Omakase Flutter app.

WARNING: This is for development only. Do not use this server as-is in production.

Setup
1. cd server/example_auth
2. cp .env.example .env and edit GOOGLE_CLIENT_ID_WEB and JWT_SECRET as needed
3. npm install
4. npm start

The server listens on port 8080 by default. When running the Flutter Android emulator, the app
should POST to `http://10.0.2.2:8080/api/auth/google`.

Endpoints
- POST /api/auth/google
  - Body: { idToken: string }
  - Verifies the idToken, creates a local user if needed, returns { ok:true, isNewUser, token, user }

- GET /api/auth/me
  - Try Bearer token or cookie 'session'
  - Returns profile info or 401
