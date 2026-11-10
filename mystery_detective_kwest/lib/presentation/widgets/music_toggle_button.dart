import 'package:flutter/material.dart';
import '../../services/music_service.dart';
import 'ui_kit.dart';

/// Кнопка включения/выключения фоновой музыки. Используется и в
/// главном меню, и на экране игры — состояние всегда берётся из
/// единственного экземпляра [MusicService].
class MusicToggleButton extends StatefulWidget {
  const MusicToggleButton({super.key});

  @override
  State<MusicToggleButton> createState() => _MusicToggleButtonState();
}

class _MusicToggleButtonState extends State<MusicToggleButton> {
  @override
  Widget build(BuildContext context) {
    final muted = MusicService.instance.muted;

    return GlassIconButton(
      tooltip: muted ? 'Включить музыку' : 'Выключить музыку',
      icon: muted ? Icons.music_off_rounded : Icons.music_note_rounded,
      onTap: () async {
        await MusicService.instance.toggleMute();
        if (mounted) setState(() {});
      },
    );
  }
}
