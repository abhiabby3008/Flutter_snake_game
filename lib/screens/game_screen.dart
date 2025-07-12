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
  static const Duration minTick = Duration(milliseconds: 50);
  static const Duration maxTick = Duration(milliseconds: 300);

  Timer? _timer;
  late Duration _currentTick;
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);
  bool _isPaused = false;

  List<Point<int>> _snake = [Point(cols ~/ 2, rows ~/ 2)];
  late Point<int> _food;
  int _score = 0;
  StickDirection _dir = StickDirection.right;

  @override
  void initState() {
    super.initState();
    _spawnFood();
    _currentTick = maxTick;
    _timer = Timer.periodic(_currentTick, (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _repaint.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isPaused) return;
    _timer?.cancel();
    _timer = Timer.periodic(_currentTick, (_) => _tick());
  }

  void _resetTimerWithNewSpeed() {
    const int baseScore = 10; // one food
    final int foodsEaten = _score ~/ baseScore;

    // Use a decay function to gradually speed up over time
    // speedFactor ∈ (0..1), where 1 means "no speed up", and 0 means "max speed"
    final double speedFactor = 1 / (1 + foodsEaten * 0.15);

    // Ease the tick duration toward minTick
    final int newMs = (minTick.inMilliseconds +
            (maxTick.inMilliseconds - minTick.inMilliseconds) * speedFactor)
        .clamp(minTick.inMilliseconds, maxTick.inMilliseconds)
        .toInt();

    final Duration newTick = Duration(milliseconds: newMs);

    if (newTick != _currentTick) {
      _currentTick = newTick;
      _timer?.cancel();
      _startTimer();
    }
    print('Speed tick: $_currentTick, foodsEaten: $foodsEaten');
  }

  void _pauseGame() {
    if (_isPaused) return;
    _isPaused = true;
    _timer?.cancel();
    setState(() {});
  }

  void _resumeGame() {
    if (!_isPaused) return;
    _isPaused = false;
    _startTimer();
    setState(() {});
  }

  void _togglePause() {
    if (_isPaused) {
      _resumeGame();
    } else {
      _pauseGame();
    }
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
    if (_isPaused) return;
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
      _timer?.cancel();
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
        _resetTimerWithNewSpeed(); // ← speed up now that we ate
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
          child: Stack(children: [
            Padding(
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
            // Pause/Resume button in top left
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(
                  _isPaused ? Icons.play_arrow : Icons.pause,
                  size: 32,
                  color: Colors.black,
                ),
                tooltip: _isPaused ? 'Resume' : 'Pause',
                onPressed: _togglePause,
              ),
            ),
          ]),
        ));
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
