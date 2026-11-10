import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/game_controller.dart';
import '../widgets/ambient.dart';
import '../widgets/house_scene.dart';
import '../widgets/music_toggle_button.dart';
import '../widgets/ui_kit.dart';
import 'game_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  Future<void> _start(BuildContext context, {bool load = false}) async {
    final game = GameController();
    if (load) {
      final ok = await game.load();
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Сохранение не найдено.')),
        );
        return;
      }
    } else {
      game.newGame();
    }
    if (!context.mounted) return;
    Navigator.push(
      context,
      softRoute(GameScreen(game: game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [MusicToggleButton(), SizedBox(width: 6)],
      ),
      body: AmbientBackground(
        kind: ParticleKind.dust,
        particleColor: p.accent,
        gradient: [
          Color.lerp(p.bg, p.accent, 0.28)!,
          Color.lerp(p.bg, p.accent, 0.06)!,
          p.bg,
        ],
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Reveal(child: HouseScene(height: 300)),
                    const SizedBox(height: 8),
                    Reveal(
                      index: 1,
                      child: ShaderMask(
                        shaderCallback: (rect) => LinearGradient(
                          colors: [Colors.white, p.accent],
                        ).createShader(rect),
                        blendMode: BlendMode.srcIn,
                        child: const _MenuTitle(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Reveal(
                      index: 2,
                      child: const _MenuSubtitle(),
                    ),
                    const SizedBox(height: 40),
                    Reveal(
                      index: 3,
                      child: GlowButton(
                        label: 'Новая игра',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () => _start(context),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Reveal(
                      index: 4,
                      child: OutlinedButton.icon(
                        onPressed: () => _start(context, load: true),
                        icon: const Icon(Icons.restore_rounded),
                        label: const Text('Продолжить'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuTitle extends StatelessWidget {
  const _MenuTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'ТАЙНА\nЗАБРОШЕННОГО ДОМА',
      textAlign: TextAlign.center,
      style: AppTheme.title(31, spacing: 3).copyWith(height: 1.2),
    );
  }
}

class _MenuSubtitle extends StatelessWidget {
  const _MenuSubtitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Мистический детектив • исследование • головоломки',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppTheme.palette.textDim,
        fontSize: 13.5,
        letterSpacing: 0.8,
        height: 1.4,
      ),
    );
  }
}
