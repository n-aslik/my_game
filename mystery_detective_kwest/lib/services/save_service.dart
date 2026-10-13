import 'package:shared_preferences/shared_preferences.dart';
import '../domain/game_controller.dart';

class SaveService {
  Future<void> save(GameController game) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('location', game.locationId);
    await p.setStringList('inventory', game.inventory.toList());
    await p.setStringList('collectedItems', game.collectedItems.toList());
    await p.setStringList('evidence', game.evidenceFound.toList());
    await p.setStringList('puzzles', game.solvedPuzzles.toList());
    await p.setStringList('locations', game.unlockedLocations.toList());
    await p.setStringList('events', game.eventsDone.toList());
    await p.setStringList('usedObjects', game.usedObjects.toList());
  }

  Future<Map<String, dynamic>?> load() async {
    final p = await SharedPreferences.getInstance();
    if (!p.containsKey('location')) return null;
    return {
      'location': p.getString('location'),
      'inventory': p.getStringList('inventory') ?? [],
      'collectedItems': p.getStringList('collectedItems') ?? [],
      'evidence': p.getStringList('evidence') ?? [],
      'puzzles': p.getStringList('puzzles') ?? [],
      'locations': p.getStringList('locations') ?? ['entrance', 'hall'],
      'events': p.getStringList('events') ?? [],
      'usedObjects': p.getStringList('usedObjects') ?? [],
    };
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
  }
}
