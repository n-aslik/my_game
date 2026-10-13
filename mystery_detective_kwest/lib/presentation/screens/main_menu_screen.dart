import 'package:flutter/material.dart';
import '../../domain/game_controller.dart';
import '../widgets/music_toggle_button.dart';
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
      MaterialPageRoute(builder: (_) => GameScreen(game: game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [MusicToggleButton()],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF211A2B), Color(0xFF07060A)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.nightlight_round, size: 88),
                const SizedBox(height: 22),
                const Text(
                  'ТАЙНА\nЗАБРОШЕННОГО ДОМА',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: 2),
                ),
                const SizedBox(height: 12),
                const Text('Мистический детектив • исследование • головоломки'),
                const SizedBox(height: 48),
                FilledButton.icon(
                  onPressed: () => _start(context),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Новая игра'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _start(context, load: true),
                  icon: const Icon(Icons.restore),
                  label: const Text('Продолжить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
