// lib/screens/game_screen.dart

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_snake/constans/theme_constants.dart';
import 'package:flutter_snake/screens/components/global_text.dart';
import 'package:flutter_snake/screens/components/snake_joystick.dart';
import 'package:flutter_snake/screens/game_over_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int rows = 20, cols = 20;
  static const tickRate = Duration(milliseconds: 200);

  late final Timer _timer;
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);

  List<Point<int>> _snake = [Point(cols ~/ 2, rows ~/ 2)];
  late Point<int> _food;
  int _score = 0;
  StickDirection _dir = StickDirection.right;

  @override
  void initState() {
    super.initState();
    _spawnFood();
    _timer = Timer.periodic(tickRate, (_) => _tick());
  }

  @override
  void dispose() {
    _timer.cancel();  
    _repaint.dispose();
    super.dispose();
  }

  void _spawnFood() {
    final rand = Random();
    Point<int> next;
    do {
      next = Point(rand.nextInt(cols), rand.nextInt(rows));
    } while (_snake.contains(next));
    _food = next;
  }

  void _tick() {
    final head = _snake.first;
    late Point<int> newHead;

    // 1) Compute the next head position based on current direction
    switch (_dir) {
      case StickDirection.up:
        newHead = Point(head.x, (head.y - 1 + rows) % rows);
        break;
      case StickDirection.down:
        newHead = Point(head.x, (head.y + 1) % rows);
        break;
      case StickDirection.left:
        newHead = Point((head.x - 1 + cols) % cols, head.y);
        break;
      case StickDirection.right:
        newHead = Point((head.x + 1) % cols, head.y);
        break;
      case StickDirection.none:
        newHead = head;
        break;
    }

    // 2) Check self‑collision
    if (newHead != head && _snake.contains(newHead)) {
      _timer.cancel();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GameOverScreen(score: _score),
        ),
      );
      return;
    }

    // 3) Update snake & score
    setState(() {
      if (newHead != head) _snake.insert(0, newHead);

      if (newHead == _food) {
        // 🎯 Haptic feedback on eating:
        HapticFeedback.lightImpact();

        _score += 10;
        _spawnFood();
        // tail stays → snake grows
      } else if (newHead != head) {
        _snake.removeLast();
      }
    });

    // 4) Only repaint the grid
    _repaint.value++;
  }

  void _onDirectionChanged(StickDirection dir) {
    if (dir == StickDirection.none) return;
    // disallow 180° turns
    if ((_dir == StickDirection.left && dir == StickDirection.right) ||
        (_dir == StickDirection.right && dir == StickDirection.left) ||
        (_dir == StickDirection.up && dir == StickDirection.down) ||
        (_dir == StickDirection.down && dir == StickDirection.up)) {
      return;
    }
    _dir = dir;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              GlobalText(
                fontSize: 35,
                text: _score.toString().padLeft(5, '0'),
                fontWeight: FontWeight.bold,
                fontFamily: "Pixelify Sans",
              ),
              const SizedBox(height: 25),
              // game pad
              AspectRatio(
                aspectRatio: cols / rows,
                child: RepaintBoundary(
                  child: Container(
                    decoration: BoxDecoration(
                      color: ThemeConstants.gamePadColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: CustomPaint(
                      painter: _SnakePainter(
                        snake: _snake,
                        food: _food,
                        rows: rows,
                        cols: cols,
                        repaint: _repaint,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 90),

              // joystick
              Center(
                child: SnakeJoystick(
                  onDirectionChanged: _onDirectionChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SnakePainter extends CustomPainter {
  final List<Point<int>> snake;
  final Point<int> food;
  final int rows, cols;

  _SnakePainter({
    required this.snake,
    required this.food,
    required this.rows,
    required this.cols,
    Listenable? repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    final paint = Paint()..style = PaintingStyle.fill;

    // food
    paint.color = ThemeConstants.foodColor;
    canvas.drawRect(
      Rect.fromLTWH(food.x * cellW, food.y * cellH, cellW, cellH),
      paint,
    );

    // snake
    paint.color = Colors.black;
    for (final seg in snake) {
      canvas.drawRect(
        Rect.fromLTWH(seg.x * cellW, seg.y * cellH, cellW, cellH),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SnakePainter old) =>
      old.snake != snake || old.food != food;
}
