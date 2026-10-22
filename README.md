# Погоня за вором — версия с общим рейтингом

Структура:
- `index.html` — игра (клиент)
- `api/[action].js` — серверная функция Vercel (регистрация, вход, статистика, рейтинг)
- `package.json` — зависимость `@upstash/redis`

## Деплой на Vercel
1. Залей эту папку в Git-репозиторий (GitHub) и импортируй в Vercel (или `vercel` из консоли).
2. В проекте: **Storage → Create / Connect Database → Upstash Redis** (Marketplace).
   Vercel сам добавит переменные окружения (`KV_REST_API_URL`, `KV_REST_API_TOKEN` или `UPSTASH_REDIS_REST_*`).
3. Сделай **Redeploy**, чтобы функция увидела переменные.
4. Открой основной домен проекта — аккаунты и рейтинг теперь общие для всех.

Локальная проверка: `npm i -g vercel && vercel dev` (после `vercel link` и `vercel env pull`).
