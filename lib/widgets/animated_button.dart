import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/sound_service.dart';

class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    super.key,
    required this.onTap,
    required this.builder,
    this.sound = WorkoutSound.buttonClick,
    this.playSound = true,
  });

  final VoidCallback? onTap;
  final Widget Function(bool isPressed) builder;
  final WorkoutSound sound;
  final bool playSound;

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  Future<void> _handleTapDown(TapDownDetails _) async {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
    HapticFeedback.heavyImpact();
    if (widget.playSound) SoundService().play(widget.sound);
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    widget.onTap!();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        curve: Curves.easeInOut,
        transform: _isPressed
            ? (Matrix4.identity()..translate(0.0, 4.0))
            : Matrix4.identity(),
        decoration: _isPressed
            ? BoxDecoration(
                borderRadius: _getBorderRadius(),
              )
            : null,
        child: _ArcadeButtonWrapper(
          isPressed: _isPressed,
          child: widget.builder(_isPressed),
        ),
      ),
    );
  }

  BorderRadius? _getBorderRadius() => null;
}

class _ArcadeButtonWrapper extends StatelessWidget {
  const _ArcadeButtonWrapper({
    required this.isPressed,
    required this.child,
  });

  final bool isPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isPressed) return child;

    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.08),
        BlendMode.darken,
      ),
      child: child,
    );
  }
}
