/* Единая serverless-функция Vercel: /api/register, /api/login, /api/me, /api/logout,
   /api/start, /api/finish, /api/leaderboard, /api/reset
   База: Upstash Redis (переменные окружения подставляет интеграция Vercel). */
const { Redis } = require('@upstash/redis');
const crypto = require('crypto');
const { promisify } = require('util');
const scrypt = promisify(crypto.scrypt);

const URL_ = process.env.UPSTASH_REDIS_REST_URL || process.env.KV_REST_API_URL;
const TOKEN_ = process.env.UPSTASH_REDIS_REST_TOKEN || process.env.KV_REST_API_TOKEN;
const redis = (URL_ && TOKEN_) ? new Redis({ url: URL_, token: TOKEN_ }) : null;

const DIFFS = ['easy', 'medium', 'hard'];
const SESSION_TTL = 60 * 60 * 24 * 30; // 30 дней
const MIN_GAME_MS = 5000;              // слишком быстрые «партии» не засчитываем
const NAME_RE = /^[\p{L}\p{N}_-]{3,16}$/u;

const emptyStats = () => ({
  games: 0, wins: 0, losses: 0, streak: 0, bestStreak: 0,
  byDiff: { easy: { w: 0, l: 0 }, medium: { w: 0, l: 0 }, hard: { w: 0, l: 0 } },
  history: []
});

const send = (res, code, data) => res.status(code).json(data);
const fail = (code, msg) => { const e = new Error(msg); e.status = code; return e; };

async function hashPass(pass, salt) {
  return (await scrypt(pass, salt, 64)).toString('hex');
}
async function newSession(key) {
  const token = crypto.randomBytes(32).toString('hex');
  await redis.set('session:' + token, key, { ex: SESSION_TTL });
  return token;
}
function bearer(req) {
  const h = req.headers.authorization || '';
  return h.startsWith('Bearer ') ? h.slice(7).trim() : null;
}
async function sessionUser(req) {
  const t = bearer(req);
  if (!t || !/^[0-9a-f]{64}$/.test(t)) return null;
  return (await redis.get('session:' + t)) || null;
}
async function requireUser(req) {
  const key = await sessionUser(req);
  if (!key) throw fail(401, 'Нужно войти в аккаунт.');
  return key;
}
async function rateLimit(req, action, limit) {
  const ip = String(req.headers['x-forwarded-for'] || 'unknown').split(',')[0].trim();
  const k = `rl:${action}:${ip}`;
  const n = await redis.incr(k);
  if (n === 1) await redis.expire(k, 60);
  if (n > limit) throw fail(429, 'Слишком много попыток. Подожди минуту.');
}
const mustBe = (req, method) => { if (req.method !== method) throw fail(405, 'Метод не поддерживается.'); };
const pct = s => s.games ? Math.round(s.wins * 100 / s.games) : 0;

module.exports = async (req, res) => {
  res.setHeader('Cache-Control', 'no-store');
  try {
    if (!redis) throw fail(500, 'База данных не подключена (нет переменных окружения Upstash).');
    const action = req.query.action;
    const body = (req.body && typeof req.body === 'object') ? req.body : {};

    switch (action) {

      case 'register': {
        mustBe(req, 'POST');
        await rateLimit(req, 'auth', 15);
        const name = String(body.name || '').trim();
        const pass = String(body.password || '');
        if (!NAME_RE.test(name)) throw fail(400, 'Имя: 3–16 символов, буквы, цифры, «_» или «-».');
        if (pass.length < 4 || pass.length > 100) throw fail(400, 'Пароль должен быть от 4 до 100 символов.');
        const key = name.toLowerCase();
        const salt = crypto.randomBytes(16).toString('hex');
        const ok = await redis.set('user:' + key, { name, salt, hash: await hashPass(pass, salt), created: Date.now() }, { nx: true });
        if (!ok) throw fail(409, 'Игрок с таким именем уже есть.');
        const stats = emptyStats();
        await redis.set('stats:' + key, stats);
        await redis.sadd('users', key);
        return send(res, 200, { token: await newSession(key), name, stats });
      }

      case 'login': {
        mustBe(req, 'POST');
        await rateLimit(req, 'auth', 15);
        const key = String(body.name || '').trim().toLowerCase();
        const pass = String(body.password || '');
        const u = key && await redis.get('user:' + key);
        if (!u) throw fail(401, 'Неверное имя или пароль.');
        const a = Buffer.from(await hashPass(pass, u.salt), 'hex');
        const b = Buffer.from(u.hash, 'hex');
        if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) throw fail(401, 'Неверное имя или пароль.');
        const stats = (await redis.get('stats:' + key)) || emptyStats();
        return send(res, 200, { token: await newSession(key), name: u.name, stats });
      }

      case 'me': {
        mustBe(req, 'GET');
        const key = await requireUser(req);
        const u = await redis.get('user:' + key);
        if (!u) throw fail(401, 'Аккаунт не найден.');
        return send(res, 200, { name: u.name, stats: (await redis.get('stats:' + key)) || emptyStats() });
      }

      case 'logout': {
        mustBe(req, 'POST');
        const t = bearer(req);
        if (t && /^[0-9a-f]{64}$/.test(t)) await redis.del('session:' + t);
        return send(res, 200, { ok: true });
      }

      case 'start': {
        mustBe(req, 'POST');
        const key = await requireUser(req);
        if (!DIFFS.includes(body.difficulty)) throw fail(400, 'Неверная сложность.');
        const gameId = crypto.randomBytes(16).toString('hex');
        await redis.set('game:' + gameId, { u: key, d: body.difficulty, t: Date.now() }, { ex: 3600 });
        return send(res, 200, { gameId });
      }

      case 'finish': {
        mustBe(req, 'POST');
        const key = await requireUser(req);
        const id = String(body.gameId || '');
        if (!/^[0-9a-f]{32}$/.test(id)) throw fail(400, 'Неверный номер партии.');
        const g = await redis.getdel('game:' + id);       // одноразовая запись: повторно не засчитать
        if (!g || g.u !== key) throw fail(400, 'Партия не найдена или уже засчитана.');
        if (Date.now() - g.t < MIN_GAME_MS) throw fail(400, 'Партия завершена слишком быстро.');
        const win = body.win === true;
        const moves = Math.max(0, Math.min(999, parseInt(body.moves, 10) || 0));
        const s = (await redis.get('stats:' + key)) || emptyStats();
        s.games++;
        if (win) { s.wins++; s.streak++; s.bestStreak = Math.max(s.bestStreak, s.streak); s.byDiff[g.d].w++; }
        else { s.losses++; s.streak = 0; s.byDiff[g.d].l++; }
        s.history.unshift({ t: Date.now(), win, diff: g.d, moves });
        s.history = s.history.slice(0, 30);
        await redis.set('stats:' + key, s);
        return send(res, 200, { stats: s });
      }

      case 'leaderboard': {
        mustBe(req, 'GET');
        const me = await sessionUser(req);
        const keys = ((await redis.smembers('users')) || []).slice(0, 2000);
        if (!keys.length) return send(res, 200, { players: [] });
        const [stats, users] = await Promise.all([
          redis.mget(...keys.map(k => 'stats:' + k)),
          redis.mget(...keys.map(k => 'user:' + k))
        ]);
        const players = keys.map((k, i) => {
          const s = stats[i] || emptyStats();
          return { name: users[i] ? users[i].name : k, wins: s.wins, losses: s.losses, games: s.games, pct: pct(s), me: k === me };
        }).sort((a, b) => b.wins - a.wins || b.pct - a.pct || a.losses - b.losses).slice(0, 50);
        return send(res, 200, { players });
      }

      case 'reset': {
        mustBe(req, 'POST');
        const key = await requireUser(req);
        const stats = emptyStats();
        await redis.set('stats:' + key, stats);
        return send(res, 200, { stats });
      }

      default:
        throw fail(404, 'Неизвестный метод.');
    }
  } catch (e) {
    if (!e.status) console.error(e);
    return send(res, e.status || 500, { error: e.status ? e.message : 'Ошибка сервера.' });
  }
};
