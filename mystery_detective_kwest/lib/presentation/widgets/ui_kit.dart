import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Плавное появление с подъёмом. [index] задаёт каскадную задержку.
class Reveal extends StatelessWidget {
  final Widget child;
  final int index;

  const Reveal({super.key, required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final delay = math.min(index, 8) * 70;
    final total = 480 + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1.0, curve: Curves.easeOutCubic),
      builder: (context, v, ch) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 18), child: ch),
      ),
      child: child,
    );
  }
}

/// Полупрозрачная «стеклянная» панель.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? tint;
  final Color? borderColor;
  final bool blur;
  final List<BoxShadow>? shadows;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 22,
    this.tint,
    this.borderColor,
    this.blur = false,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette;
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (tint ?? Colors.white).withValues(alpha: tint == null ? 0.07 : 0.16),
            (tint ?? p.surface).withValues(alpha: tint == null ? 0.55 : 0.08),
          ],
        ),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.09),
        ),
        boxShadow: shadows,
      ),
      child: child,
    );

    if (!blur) return box;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: box,
      ),
    );
  }
}

/// Круглая стеклянная кнопка-иконка (с необязательным бейджем).
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final int badge;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette;
    Widget ic = Icon(icon, size: 21, color: p.text);
    if (badge > 0) {
      ic = Badge(
        label: Text('$badge'),
        backgroundColor: p.accent,
        textColor: const Color(0xFF14101C),
        child: ic,
      );
    }
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 26,
        child: Container(
          width: 42,
          height: 42,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.07),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: ic,
        ),
      ),
    );
  }
}

/// Заголовок секции: акцентная черта + капслок.
class SectionLabel extends StatelessWidget {
  final String text;
  final IconData? icon;
  final String? trailing;

  const SectionLabel(this.text, {super.key, this.icon, this.trailing});

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette;
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: p.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          if (icon != null) ...[
            Icon(icon, size: 16, color: p.accent),
            const SizedBox(width: 6),
          ],
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.2,
              color: p.textDim,
            ),
          ),
          const Spacer(),
          if (trailing != null)
            Text(
              trailing!,
              style: TextStyle(fontSize: 12, color: p.textDim),
            ),
        ],
      ),
    );
  }
}

/// Маленькая «таблетка» с текстом.
class Pill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;

  const Pill(this.text, {super.key, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.palette.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: c),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}

/// Главная кнопка с градиентом и свечением.
class GlowButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const GlowButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette;
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: LinearGradient(
            colors: [p.accent, Color.lerp(p.accent, p.accent2, 0.55)!],
          ),
          boxShadow: [
            BoxShadow(
              color: p.accent.withValues(alpha: 0.45),
              blurRadius: 28,
              spreadRadius: -2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 17),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: const Color(0xFF14101C)),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF14101C),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Тряска при неверном ответе: меняйте [trigger], чтобы запустить.
class Shake extends StatefulWidget {
  final int trigger;
  final Widget child;

  const Shake({super.key, required this.trigger, required this.child});

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(covariant Shake old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final dx = math.sin(_c.value * math.pi * 6) * (1 - _c.value) * 12;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }
}

/// Печать текста по буквам.
class Typewriter extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int msPerChar;

  const Typewriter(this.text, {super.key, this.style, this.msPerChar = 16});

  @override
  Widget build(BuildContext context) {
    final len = text.length;
    return TweenAnimationBuilder<int>(
      key: ValueKey(text),
      tween: IntTween(begin: 0, end: len),
      duration: Duration(milliseconds: math.min(len * msPerChar, 3500)),
      builder: (context, n, _) => Text(text.substring(0, n), style: style),
    );
  }
}

/// Мягко пульсирующее свечение вокруг [child].
class PulseGlow extends StatefulWidget {
  final Widget child;
  final Color color;
  final double radius;

  const PulseGlow({
    super.key,
    required this.child,
    required this.color,
    this.radius = 60,
  });

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final k = Curves.easeInOut.transform(_c.value);
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.20 + 0.25 * k),
                blurRadius: widget.radius * (0.8 + 0.5 * k),
                spreadRadius: widget.radius * 0.1 * k,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}
