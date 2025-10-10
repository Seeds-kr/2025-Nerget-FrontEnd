require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');
const { OAuth2Client } = require('google-auth-library');
const jwt = require('jsonwebtoken');

const app = express();
app.use(bodyParser.json());
app.use(cookieParser());

const CLIENT_ID = process.env.GOOGLE_CLIENT_ID_WEB || '';
const JWT_SECRET = process.env.JWT_SECRET || 'dev_jwt_secret_change_me';
const PORT = process.env.PORT || 8080;

if (!CLIENT_ID) {
    console.warn('[example_auth] WARNING: GOOGLE_CLIENT_ID_WEB not set in .env');
}

const client = new OAuth2Client(CLIENT_ID);

async function verifyIdToken(idToken) {
    const ticket = await client.verifyIdToken({ idToken, audience: CLIENT_ID });
    return ticket.getPayload();
}

// Simple in-memory "user" store for example only
const users = new Map();

app.post('/api/auth/google', async (req, res) => {
    const { idToken } = req.body || {};
    if (!idToken) return res.status(400).json({ ok: false, reason: 'missing_id_token' });

    try {
        const payload = await verifyIdToken(idToken);
        // payload: sub, email, email_verified, name, picture, aud, iss, exp
        if (!payload.email_verified) {
            return res.status(403).json({ ok: false, reason: 'email_not_verified' });
        }

        const providerId = payload.sub;
        let user = users.get(providerId);
        const isNew = !user;
        if (!user) {
            user = { id: providerId, email: payload.email, name: payload.name, picture: payload.picture };
            users.set(providerId, user);
        }

        // issue simple JWT (access token). In production, use refresh tokens, DB-backed sessions, etc.
        const accessToken = jwt.sign({ uid: user.id, email: user.email }, JWT_SECRET, { expiresIn: '1h' });

        // Optionally set cookie for web clients
        res.cookie('session', accessToken, {
            httpOnly: true,
            secure: false, // set true in production (HTTPS)
            sameSite: 'lax',
        });

        return res.json({ ok: true, isNewUser: isNew, token: accessToken, user });
    } catch (err) {
        console.error('[example_auth] token verify error', err);
        return res.status(401).json({ ok: false, reason: 'invalid_id_token' });
    }
});

app.get('/api/auth/me', (req, res) => {
    // try Bearer first
    const auth = req.headers.authorization;
    let token = null;
    if (auth && auth.startsWith('Bearer ')) token = auth.substring(7);
    if (!token && req.cookies && req.cookies.session) token = req.cookies.session;
    if (!token) return res.status(401).json({ ok: false, reason: 'no_token' });

    try {
        const data = jwt.verify(token, JWT_SECRET);
        const user = users.get(data.uid) || { id: data.uid, email: data.email };
        return res.json({ ok: true, profileCompleted: !!user.name, user });
    } catch (err) {
        return res.status(401).json({ ok: false, reason: 'invalid_token' });
    }
});

app.listen(PORT, () => console.log(`[example_auth] listening ${PORT}`));
