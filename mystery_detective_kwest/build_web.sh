#!/bin/bash
# Сборка Flutter Web на Vercel: в окружении Vercel нет Flutter,
# поэтому скачиваем его при каждой сборке и собираем сайт в build/web.
set -e

if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 --branch stable "$HOME/flutter"
fi
export PATH="$HOME/flutter/bin:$PATH"
export FLUTTER_SUPPRESS_ANALYTICS=true

flutter config --enable-web --no-analytics
flutter doctor -v || true
flutter pub get
flutter build web --release
