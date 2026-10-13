import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/main_menu_screen.dart';
import 'services/music_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Музыка запускается сразу при старте приложения и звучит фоном
  // на всех экранах — от главного меню до финальных титров.
  MusicService.instance.init();
  runApp(const MysticDetectiveApp());
}

class MysticDetectiveApp extends StatefulWidget {
  const MysticDetectiveApp({super.key});

  @override
  State<MysticDetectiveApp> createState() => _MysticDetectiveAppState();
}

class _MysticDetectiveAppState extends State<MysticDetectiveApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    MusicService.instance.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Ставим музыку на паузу, когда приложение уходит в фон,
    // и возобновляем при возврате (если звук не был выключен вручную).
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      MusicService.instance.pause();
    } else if (state == AppLifecycleState.resumed) {
      MusicService.instance.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Тайна заброшенного дома 2: Дом между эпохами',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      // Любое касание запускает музыку, если браузер заблокировал автозапуск.
      builder: (context, child) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => MusicService.instance.ensurePlaying(),
        child: child,
      ),
      home: const MainMenuScreen(),
    );
  }
}
