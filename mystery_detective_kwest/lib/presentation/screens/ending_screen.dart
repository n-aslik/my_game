import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../../domain/game_controller.dart';

class EndingScreen extends StatelessWidget {
  final GameController game;
  final List<Ending> available;

  const EndingScreen({super.key, required this.game, required this.available});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Финал расследования')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.flag, size: 80),
          const SizedBox(height: 18),
          const Text(
            'Ваши выводы зависят от собранных доказательств.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (available.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Пока недостаточно доказательств для финала. Продолжайте расследование.'),
              ),
            ),
          ...available.map((e) => Card(
            child: ListTile(
              title: Text(e.title),
              subtitle: Text(e.text),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(e.title),
                  content: Text(e.text),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть')),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
