import 'package:flutter/material.dart';
import '../../data/game_data.dart';
import '../../data/models/models.dart';
import '../../domain/game_controller.dart';

class EvidenceScreen extends StatelessWidget {
  final GameController game;
  const EvidenceScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final found = evidence.where((e) => game.evidenceFound.contains(e.id)).toList();
    final progress = evidence.isEmpty ? 0.0 : found.length / evidence.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Расследование')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text('Улики', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Собрано ${found.length} из ${evidence.length}'),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: progress, minHeight: 8),
          ),
          const SizedBox(height: 12),
          if (found.isEmpty) const Text('Пока ничего не найдено.'),
          ...found.map((e) => Card(
            child: ListTile(
              leading: Icon(_icon(e.type)),
              title: Text(e.title),
              subtitle: Text(e.description),
            ),
          )),
          const SizedBox(height: 20),
          Text('Связи', style: Theme.of(context).textTheme.headlineSmall),
          ...links.where((l) => game.evidenceFound.contains(l.fromId) && game.evidenceFound.contains(l.toId)).map(
            (l) => Card(
              child: ListTile(
                leading: const Icon(Icons.link),
                title: Text('${_name(l.fromId)} → ${_name(l.toId)}'),
                subtitle: Text(l.explanation),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon(EvidenceType type) {
    switch (type) {
      case EvidenceType.photograph: return Icons.photo;
      case EvidenceType.document: return Icons.description;
      case EvidenceType.symbol: return Icons.auto_awesome;
      case EvidenceType.audio: return Icons.graphic_eq;
      case EvidenceType.testimony: return Icons.record_voice_over;
      case EvidenceType.object: return Icons.inventory_2;
    }
  }

  String _name(String id) => evidence.firstWhere((e) => e.id == id).title;
}
