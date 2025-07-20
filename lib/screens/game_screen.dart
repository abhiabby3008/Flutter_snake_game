import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_snake/constans/theme_constants.dart';
import 'package:flutter_snake/screens/components/global_text.dart';
import 'package:flutter_snake/screens/components/snake_joystick.dart';
import 'package:flutter_snake/screens/components/touch_arrow_controls.dart';
import 'package:flutter_snake/screens/components/swipe_controls.dart';
import 'package:flutter_snake/screens/components/countdown_widget.dart';
import 'package:flutter_snake/screens/game_over_screen.dart';
import 'package:flutter_snake/screens/settings_screen.dart';
import 'package:flutter_snake/models/game_settings.dart';
import 'package:flutter_snake/services/score_manager.dart'; // Add this import

class GameScreen extends StatefulWidget {
  final GameSettings? initialSettings;
  const GameScreen({Key? key, this.initialSettings}) : super(key: key);
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  static const int rows = 20, cols = 20;
  static const Duration minTick = Duration(milliseconds: 50);
  static const Duration maxTick = Duration(milliseconds: 300);

  Timer? _timer;
  late Duration _currentTick;
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);
  bool _isPaused = false;
  bool _showCountdown = true;
  bool _gameStarted = false;
  bool _showResumeCountdown = false;
  late GameSettings _gameSettings;

  StickDirection? _lastSwipeDirection;

  List<Point<int>> _snake = [Point(cols ~/ 2, rows ~/ 2)];
  late Point<int> _food;
  int _score = 0;
  int _highScore = 0; // Add high score variable
  StickDirection _dir = StickDirection.right;

  // Add missing _controlType getter
  ControlType get _controlType => _gameSettings.controlType;

  // Swipe detection variables
  Offset? _swipeStartPosition;
  DateTime? _swipeStartTime;
  static const double minSwipeDistance = 30.0;
  static const int maxSwipeTime = 600;
  static const double velocityThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _gameSettings = widget.initialSettings ?? const GameSettings();
    _spawnFood();
    _currentTick = _gameSettings.maxTick;
    _loadHighScore(); // Load high score on init
    // Don't start timer immediately - wait for countdown
  }

  // Add method to load high score
  void _loadHighScore() async {
    final highScore = await ScoreManager.instance.getHighScore();
    setState(() {
      _highScore = highScore;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _repaint.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App going to background or becoming inactive
        if (_gameStarted && !_isPaused) {
          _pauseGame();
        }
        break;
      case AppLifecycleState.resumed:
        // App coming back from background
        if (_gameStarted && _isPaused) {
          _showResumeCountdownDialog();
        }
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
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

    // Use difficulty-based min/max tick from settings
    final int newMs = (_gameSettings.minTick.inMilliseconds +
            (_gameSettings.maxTick.inMilliseconds -
                    _gameSettings.minTick.inMilliseconds) *
                speedFactor)
        .clamp(_gameSettings.minTick.inMilliseconds,
            _gameSettings.maxTick.inMilliseconds)
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
      _showResumeCountdownDialog();
    } else {
      _pauseGame();
    }
  }

  void _showResumeCountdownDialog() {
    setState(() {
      _showResumeCountdown = true;
    });
  }

  void _onInitialCountdownComplete() {
    setState(() {
      _showCountdown = false;
      _gameStarted = true;
    });
    _startTimer();
  }

  void _onResumeCountdownComplete() {
    setState(() {
      _showResumeCountdown = false;
    });
    _resumeGame();
  }

  void _cancelResume() {
    setState(() {
      _showResumeCountdown = false;
    });
    // Keep the game paused
  }

  void _spawnFood() {
    final rand = Random();
    Point<int> next;
    do {
      next = Point(rand.nextInt(cols), rand.nextInt(rows));
    } while (_snake.contains(next));
    _food = next;
  }

  // Add missing _calculateNewPosition method INSIDE the class
  Point<int> _calculateNewPosition(Point<int> head, int dx, int dy) {
    int newX = head.x + dx;
    int newY = head.y + dy;

    switch (_gameSettings.gameType) {
      case GameType.classic:
        // No wrapping - boundaries cause game over
        return Point(newX, newY);

      case GameType.borderless:
        // Wrap around boundaries
        newX = (newX + cols) % cols;
        newY = (newY + rows) % rows;
        return Point(newX, newY);

      case GameType.portal:
        // Portal mode - wrap around with special effects
        if (newX < 0) newX = cols - 1;
        if (newX >= cols) newX = 0;
        if (newY < 0) newY = rows - 1;
        if (newY >= rows) newY = 0;
        return Point(newX, newY);
    }
  }

  // Add missing _shouldGameOver method INSIDE the class
  bool _shouldGameOver(Point<int> newHead, Point<int> currentHead) {
    // Check self-collision (always causes game over)
    if (_snake.contains(newHead)) {
      return true;
    }

    // Check boundary collision based on game type
    switch (_gameSettings.gameType) {
      case GameType.classic:
        // Game over if hitting boundaries
        return newHead.x < 0 ||
            newHead.x >= cols ||
            newHead.y < 0 ||
            newHead.y >= rows;

      case GameType.borderless:
      case GameType.portal:
        // No boundary game over for these modes
        return false;
    }
  }

  // Fix the _openSettings method
  void _openSettings() async {
    _pauseGame(); // Pause the game while in settings

    final result = await Navigator.of(context).push<GameSettings>(
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          currentSettings: _gameSettings,
          onSettingsChanged: (GameSettings newSettings) {
            // This callback is called immediately when settings change
            // but we also need to handle the result when returning
          },
        ),
      ),
    );

    if (result != null) {
      _onSettingsChanged(result);
    }

    // Show resume countdown when returning from settings
    if (_gameStarted) {
      _showResumeCountdownDialog();
    }
  }

  // Add missing _onSettingsChanged callback INSIDE the class
  void _onSettingsChanged(GameSettings newSettings) {
    setState(() {
      _gameSettings = newSettings;
      // Recalculate speed based on new difficulty
      _resetTimerWithNewSpeed();
    });
  }

  void _tick() {
    if (_isPaused) return;
    final head = _snake.first;
    late Point<int> newHead;

    // 1) Compute the next head position based on current direction and game type
    switch (_dir) {
      case StickDirection.up:
        newHead = _calculateNewPosition(head, 0, -1);
        break;
      case StickDirection.down:
        newHead = _calculateNewPosition(head, 0, 1);
        break;
      case StickDirection.left:
        newHead = _calculateNewPosition(head, -1, 0);
        break;
      case StickDirection.right:
        newHead = _calculateNewPosition(head, 1, 0);
        break;
      case StickDirection.none:
        newHead = head;
        break;
    }

    // 2) Check game-over conditions based on game type
    if (_shouldGameOver(newHead, head)) {
      _timer?.cancel();
      // Save score before navigating to game over screen
      _saveScoreAndNavigate();
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
        _resetTimerWithNewSpeed();
      } else {
        _snake.removeLast();
      }
    });

    _repaint.value++;
  }

  // Add method to save score and navigate
  void _saveScoreAndNavigate() async {
    await ScoreManager.instance.saveCurrentScore(_score);
    final isNewHighScore = await ScoreManager.instance.saveHighScore(_score);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GameOverScreen(
            score: _score,
            isNewHighScore: isNewHighScore,
          ),
        ),
      );
    }
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

  // Full-screen swipe detection methods
  void _onPanStart(DragStartDetails details) {
    if (_controlType != ControlType.swipe) return;
    _swipeStartPosition = details.globalPosition;
    _swipeStartTime = DateTime.now();
  }

  void _onPanEnd(DragEndDetails details) {
    if (_controlType != ControlType.swipe ||
        _swipeStartPosition == null ||
        _swipeStartTime == null) return;

    final currentTime = DateTime.now();
    final swipeDuration =
        currentTime.difference(_swipeStartTime!).inMilliseconds;

    // Check if swipe was too slow
    if (swipeDuration > maxSwipeTime) {
      _resetSwipeState();
      return;
    }

    final velocity = details.velocity.pixelsPerSecond;
    final dx = velocity.dx;
    final dy = velocity.dy;

    StickDirection? direction;

    // Use velocity for more responsive detection
    if (dx.abs() > dy.abs()) {
      // Horizontal swipe
      if (dx.abs() > velocityThreshold) {
        direction = dx > 0 ? StickDirection.right : StickDirection.left;
      }
    } else {
      // Vertical swipe
      if (dy.abs() > velocityThreshold) {
        direction = dy > 0 ? StickDirection.down : StickDirection.up;
      }
    }

    if (direction != null) {
      _handleSwipeDirection(direction);
    }

    _resetSwipeState();
  }

  void _handleSwipeDirection(StickDirection direction) {
    setState(() {
      _lastSwipeDirection = direction;
    });

    // Clear the swipe direction after animation
    Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _lastSwipeDirection = null;
        });
      }
    });

    _onDirectionChanged(direction);
  }

  void _resetSwipeState() {
    _swipeStartPosition = null;
    _swipeStartTime = null;
  }

  // Add the missing restart dialog method
  void _showRestartDialog() {
    // Pause the game first if it's currently running
    if (_gameStarted && !_isPaused) {
      _pauseGame();
    }

    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ThemeConstants.gameOverColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ThemeConstants.foodColor,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: ThemeConstants.foodColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Retro-style title
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: ThemeConstants.foodColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const GlobalText(
                    fontSize: 20,
                    text: '⚠️ RESTART GAME ⚠️',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Pixelify Sans",
                  ),
                ),
                const SizedBox(height: 20),
                // Warning message
                const GlobalText(
                  fontSize: 16,
                  text: 'Are you sure you want to\\nrestart the current game?',
                  color: ThemeConstants.textColorWhite,
                  textAlign: TextAlign.center,
                  fontFamily: "Pixelify Sans",
                ),
                const SizedBox(height: 8),
                const GlobalText(
                  fontSize: 14,
                  text: 'Your current progress will be lost!',
                  color: Colors.redAccent,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 24),
                // Action buttons
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                          // Resume the game if it was running before the dialog
                          if (_gameStarted && _isPaused) {
                            _showResumeCountdownDialog();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade600,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: const GlobalText(
                            fontSize: 16,
                            text: 'CANCEL',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                            fontFamily: "Pixelify Sans",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Restart button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          Navigator.of(context).pop();
                          _restartGame();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: ThemeConstants.foodColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    ThemeConstants.foodColor.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const GlobalText(
                            fontSize: 16,
                            text: 'RESTART',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                            fontFamily: "Pixelify Sans",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add the missing restart game method
  void _restartGame() {
    setState(() {
      _score = 0;
      _currentTick = _gameSettings.maxTick;
      _snake = [Point(cols ~/ 2, rows ~/ 2)];
      _dir = StickDirection.right;
      _isPaused = false;
      _showCountdown = true;
      _gameStarted = false;
      _showResumeCountdown = false;
    });
    _spawnFood();
    _timer?.cancel();
    // The countdown will start the timer when it completes
  }

  Widget _buildCurrentControl() {
    switch (_gameSettings.controlType) {
      case ControlType.joystick:
        return SnakeJoystick(
          onDirectionChanged: _onDirectionChanged,
        );
      case ControlType.touchArrows:
        return TouchArrowControls(
          onDirectionChanged: _onDirectionChanged,
        );
      case ControlType.swipe:
        return SwipeControls(
          onDirectionChanged: _onDirectionChanged,
          lastSwipeDirection: _lastSwipeDirection,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundColor,
      body: Stack(
        children: [
          // Main game UI
          GestureDetector(
            // Full-screen swipe detection
            onPanStart: _onPanStart,
            onPanEnd: _onPanEnd,
            behavior: HitTestBehavior.translucent,
            child: SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Score section with high score
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GlobalText(
                                  fontSize: 35,
                                  text: _score.toString().padLeft(5, '0'),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Pixelify Sans",
                                ),
                                // High score display
                                Row(
                                  children: [
                                    const GlobalText(
                                      fontSize: 12,
                                      text: 'Best: ',
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    GlobalText(
                                      fontSize: 12,
                                      text:
                                          _highScore.toString().padLeft(5, '0'),
                                      color: ThemeConstants.foodColor,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Pixelify Sans",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Difficulty indicator only
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    ThemeConstants.snakeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: ThemeConstants.snakeColor
                                        .withOpacity(0.3)),
                              ),
                              child: GlobalText(
                                fontSize: 12,
                                text: _gameSettings.difficultyName,
                                color: ThemeConstants.snakeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        // Game pad
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
                        // Dynamic control widget
                        Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: _buildCurrentControl(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Top right controls - Pause and Settings buttons
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Settings button
                        Container(
                          decoration: BoxDecoration(
                            color:
                                ThemeConstants.joyStickColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black26),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.settings,
                              size: 24,
                              color: Colors.black,
                            ),
                            tooltip: 'Settings',
                            onPressed: _openSettings,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Restart button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade300),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              size: 24,
                              color: Colors.orange,
                            ),
                            tooltip: 'Restart Game',
                            onPressed: _showRestartDialog,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Pause/Resume button
                        Container(
                          decoration: BoxDecoration(
                            color:
                                ThemeConstants.joyStickColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black26),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isPaused ? Icons.play_arrow : Icons.pause,
                              size: 24,
                              color: Colors.black,
                            ),
                            tooltip: _isPaused ? 'Resume' : 'Pause',
                            onPressed: _togglePause,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Game type and control indicators
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Game type indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _gameSettings.gameType == GameType.classic
                                    ? Icons.stop
                                    : _gameSettings.gameType ==
                                            GameType.borderless
                                        ? Icons.all_out
                                        : Icons.compare_arrows,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              GlobalText(
                                fontSize: 11,
                                text: _gameSettings.gameTypeName,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                        if (_gameSettings.controlType == ControlType.swipe)
                          const SizedBox(height: 6),
                        // Swipe mode indicator
                        if (_gameSettings.controlType == ControlType.swipe)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: ThemeConstants.foodColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.swipe,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                GlobalText(
                                  fontSize: 11,
                                  text: 'Swipe Mode',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Initial countdown overlay
          if (_showCountdown)
            CountdownWidget(
              title: 'Get Ready!',
              onCountdownComplete: _onInitialCountdownComplete,
            ),
          // Resume countdown overlay
          if (_showResumeCountdown)
            CountdownWidget(
              title: 'Game Paused',
              showResumeButton: true,
              onCountdownComplete: _onResumeCountdownComplete,
              onCancel: _cancelResume,
            ),
        ],
      ),
    );
  }
} // End of _GameScreenState class

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
