{{flutter_js}}
{{flutter_build_config}}

// Запускаем Flutter внутри контейнера #game, чтобы под игрой осталось место для рекламы.
_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine({
      hostElement: document.querySelector('#game'),
    });
    await appRunner.runApp();
  },
});
