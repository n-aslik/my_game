import 'package:flutter/material.dart';
import '../../data/game_data.dart';
import '../../domain/game_controller.dart';

class DialogueScreen extends StatefulWidget {
  final GameController game;
  const DialogueScreen({super.key, required this.game});

  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  String? response;

  @override
  Widget build(BuildContext context) {
    final dialogue = dialogues.first;
    final available = dialogue.options.where(
      (o) => o.available(widget.game.evidenceFound, widget.game.inventory),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Разговор')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 42)),
          const SizedBox(height: 16),
          Text(dialogue.intro, style: Theme.of(context).textTheme.titleLarge),
          if (response != null) ...[
            const SizedBox(height: 20),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(response!))),
          ],
          const SizedBox(height: 20),
          ...available.map((o) => FilledButton.tonal(
            onPressed: () => setState(() {
              response = o.response;
              if (o.grantsEvidenceId != null) {
                widget.game.collectEvidence(o.grantsEvidenceId!);
              }
            }),
            child: Align(alignment: Alignment.centerLeft, child: Text(o.text)),
          )),
        ],
      ),
    );
  }
}
