// lib/screens/components/snake_joystick.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter_snake/constans/theme_constants.dart';

enum StickDirection { up, down, left, right, none }

class SnakeJoystick extends StatefulWidget {
  final void Function(StickDirection dir) onDirectionChanged;
  const SnakeJoystick({Key? key, required this.onDirectionChanged})
      : super(key: key);

  @override
  _SnakeJoystickState createState() => _SnakeJoystickState();
}

class _SnakeJoystickState extends State<SnakeJoystick> {
  StickDirection _current = StickDirection.none;

  @override
  Widget build(BuildContext context) {
    return Joystick(
      mode: JoystickMode.horizontalAndVertical,
      stick: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          color: ThemeConstants.joyStickColor,
          shape: BoxShape.circle,
        ),
      ),
      base: CustomPaint(
        size: const Size(200, 200),
        painter: _JoystickBasePainter(
          highlight: _current,
          baseColor: ThemeConstants.joyStickColor.withOpacity(0.5),
          highlightColor: ThemeConstants.foodColor,
        ),
      ),
      listener: (details) {
        final dx = details.x, dy = details.y;
        StickDirection dir;
        if (dx.abs() > dy.abs()) {
          dir = dx > 0 ? StickDirection.right : StickDirection.left;
        } else if (dy.abs() > dx.abs()) {
          dir = dy > 0 ? StickDirection.down : StickDirection.up;
        } else {
          dir = StickDirection.none;
        }

        // Highlight the correct quadrant
        if (dir != _current) setState(() => _current = dir);

        // Only notify on real directions
        if (dir != StickDirection.none) {
          widget.onDirectionChanged(dir);
        }
      },
    );
  }
}

class _JoystickBasePainter extends CustomPainter {
  final StickDirection highlight;
  final Color baseColor;
  final Color highlightColor;

  _JoystickBasePainter({
    required this.highlight,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final segments = <StickDirection, double>{
      StickDirection.right: -pi / 4,
      StickDirection.down: pi / 4,
      StickDirection.left: 3 * pi / 4,
      StickDirection.up: 5 * pi / 4,
    };

    segments.forEach((dir, startAngle) {
      paint.color = (dir == highlight) ? highlightColor : baseColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        pi / 2,
        true,
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _JoystickBasePainter old) =>
      old.highlight != highlight;
}
