// lib/screens/game_over_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_snake/constans/theme_constants.dart';
import 'package:flutter_snake/screens/components/global_text.dart';
import 'package:flutter_snake/screens/game_screen.dart';
import 'package:flutter_snake/screens/settings_screen.dart';
import 'package:flutter_snake/services/score_manager.dart';
import 'package:flutter_snake/models/game_settings.dart';

class GameOverScreen extends StatefulWidget {
  final int score;
  final bool isNewHighScore;
  final GameSettings? gameSettings;

  const GameOverScreen({
    super.key,
    required this.score,
    this.isNewHighScore = false,
    this.gameSettings,
  });

  @override
  _GameOverScreenState createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with TickerProviderStateMixin {
  int _highScore = 0;
  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnimation;
  late GameSettings _currentSettings;

  @override
  void initState() {
    super.initState();
    _loadHighScore();

    // Initialize settings with defaults if not provided
    _currentSettings = widget.gameSettings ?? GameSettings();

    // Setup celebration animation for new high score
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _celebrationAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    if (widget.isNewHighScore) {
      _celebrationController.repeat(reverse: true);
    }
  }

  void _loadHighScore() async {
    final highScore = await ScoreManager.instance.getHighScore();
    setState(() {
      _highScore = highScore;
    });
  }

  void _openSettings() async {
    final result = await Navigator.of(context).push<GameSettings>(
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          currentSettings: _currentSettings,
          onSettingsChanged: (settings) {
            // This callback is for real-time updates during settings changes
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _currentSettings = result;
      });
    }
  }

  void _playAgain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameScreen(initialSettings: _currentSettings),
      ),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.gameOverColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // New High Score celebration
            if (widget.isNewHighScore) ...[
              AnimatedBuilder(
                animation: _celebrationAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _celebrationAnimation.value,
                    child: const GlobalText(
                      fontSize: 24,
                      color: ThemeConstants.foodColor,
                      fontFamily: "Pixelify Sans",
                      text: "🎉 NEW HIGH SCORE! 🎉",
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],

            const GlobalText(
                fontSize: 40,
                color: ThemeConstants.textColorWhite,
                fontFamily: "Pixelify Sans",
                text: "Game Over"),
            const SizedBox(
              height: 20,
            ),
            const GlobalText(
              text: 'Your Score',
              fontSize: 20,
              color: ThemeConstants.textColorWhite,
            ),
            const SizedBox(height: 8),
            GlobalText(
              text: widget.score.toString().padLeft(5, '0'),
              fontSize: 30,
              fontFamily: "Pixelify Sans",
              color: ThemeConstants.foodColor,
            ),

            // High Score Display
            const SizedBox(height: 16),
            const GlobalText(
              text: 'Highest Score',
              fontSize: 16,
              color: Colors.white70,
            ),
            const SizedBox(height: 4),
            GlobalText(
              text: _highScore.toString().padLeft(5, '0'),
              fontSize: 24,
              fontFamily: "Pixelify Sans",
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),

            const SizedBox(height: 40),

            // Settings Button
            GestureDetector(
              onTap: _openSettings,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: ThemeConstants.gamePadColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: ThemeConstants.textColorWhite.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.settings,
                      size: 24,
                      color: ThemeConstants.textColorWhite,
                    ),
                    SizedBox(width: 8),
                    GlobalText(
                      fontSize: 18,
                      text: 'Settings',
                      color: ThemeConstants.textColorWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Play Again Button
            GestureDetector(
              onTap: _playAgain,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: ThemeConstants.foodColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeConstants.foodColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.refresh,
                      size: 28,
                      color: Colors.white,
                    ),
                    SizedBox(width: 12),
                    GlobalText(
                      fontSize: 20,
                      text: 'Play Again',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
