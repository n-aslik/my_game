# Погоня за вором — версия с общим рейтингом (Netlify)

Структура:
- `public/index.html` — игра (клиент)
- `netlify/functions/api.mjs` — серверная функция Netlify (регистрация, вход, статистика, рейтинг), отвечает на `/api/*`
- `netlify.toml` — настройки сборки
- `package.json` — зависимость `@upstash/redis`

## Деплой на Netlify
1. Залей эту папку в Git-репозиторий (GitHub) и импортируй в Netlify (**Add new site → Import an existing project**).
   Настройки сборки подхватятся из `netlify.toml` (publish: `public`, build command не нужна).
2. Создай бесплатную базу **Upstash Redis** на https://upstash.com (или через Netlify Extensions → Upstash, если доступно)
   и скопируй **REST URL** и **REST Token**.
3. В Netlify: **Site configuration → Environment variables** добавь:
   - `UPSTASH_REDIS_REST_URL`
   - `UPSTASH_REDIS_REST_TOKEN`
4. Сделай **Deploys → Trigger deploy → Clear cache and deploy site**, чтобы функция увидела переменные.
5. Открой домен сайта — аккаунты и рейтинг общие для всех.

Локальная проверка: `npm i -g netlify-cli && netlify link && netlify dev`
(переменные окружения подтянутся из сайта, либо положи их в файл `.env`).
