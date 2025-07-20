import 'package:flutter/material.dart';
import 'package:flutter_snake/constans/theme_constants.dart';
import 'package:flutter_snake/screens/components/global_text.dart';
import 'package:flutter_snake/screens/components/snake_joystick.dart';
import 'package:flutter_snake/screens/game_screen.dart';
import 'package:flutter_snake/screens/settings_screen.dart';
import 'package:flutter_snake/models/game_settings.dart';
import 'package:flutter_snake/services/score_manager.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({super.key});

  @override
  _OnBoardScreenState createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  GameSettings _gameSettings = const GameSettings();
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final highScore = await ScoreManager.instance.getHighScore();
    setState(() {
      _highScore = highScore;
    });
  }

  void _openSettings() async {
    final result = await Navigator.of(context).push<GameSettings>(
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          currentSettings: _gameSettings,
          onSettingsChanged: (GameSettings newSettings) {},
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _gameSettings = result;
      });
    }
  }

  void _startGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameScreen(initialSettings: _gameSettings),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.gameOverColor,
      body: Stack(
        children: [
          // Settings button in top right
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.settings,
                  size: 28,
                  color: Colors.white,
                ),
                tooltip: 'Settings',
                onPressed: _openSettings,
              ),
            ),
          ),
          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game title
              const Center(
                child: GlobalText(
                  fontSize: 50,
                  text: "SNAKE",
                  fontFamily: "Pixelify Sans",
                  color: ThemeConstants.textColorWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Subtitle
              const Center(
                child: GlobalText(
                  fontSize: 18,
                  text: "Classic Arcade Game",
                  fontFamily: "Pixelify Sans",
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              // High Score Display
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: ThemeConstants.foodColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: ThemeConstants.foodColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 24,
                      color: ThemeConstants.foodColor,
                    ),
                    const SizedBox(width: 8),
                    GlobalText(
                      fontSize: 16,
                      text: "High Score: $_highScore",
                      fontFamily: "Pixelify Sans",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Current settings preview
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const GlobalText(
                      fontSize: 16,
                      text: "Current Settings",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSettingItem(
                          icon: _getControlIcon(),
                          label: _getControlName(),
                        ),
                        _buildSettingItem(
                          icon: Icons.speed,
                          label: _gameSettings.difficultyName,
                        ),
                        _buildSettingItem(
                          icon: _getGameTypeIcon(),
                          label: _gameSettings.gameTypeName,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Start game button
              GestureDetector(
                onTap: _startGame,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeConstants.foodColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow,
                        size: 32,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      GlobalText(
                        fontSize: 20,
                        text: "START GAME",
                        fontFamily: "Pixelify Sans",
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Settings hint
              GestureDetector(
                onTap: _openSettings,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.settings,
                        size: 16,
                        color: Colors.white60,
                      ),
                      SizedBox(width: 6),
                      GlobalText(
                        fontSize: 14,
                        text: "Tap to customize settings",
                        color: Colors.white60,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Colors.white70,
        ),
        const SizedBox(height: 4),
        GlobalText(
          fontSize: 12,
          text: label,
          color: Colors.white70,
        ),
      ],
    );
  }

  IconData _getControlIcon() {
    switch (_gameSettings.controlType) {
      case ControlType.joystick:
        return Icons.radio_button_unchecked;
      case ControlType.touchArrows:
        return Icons.keyboard_arrow_up;
      case ControlType.swipe:
        return Icons.swipe;
    }
  }

  String _getControlName() {
    switch (_gameSettings.controlType) {
      case ControlType.joystick:
        return 'Joystick';
      case ControlType.touchArrows:
        return 'Arrows';
      case ControlType.swipe:
        return 'Swipe';
    }
  }

  IconData _getGameTypeIcon() {
    switch (_gameSettings.gameType) {
      case GameType.classic:
        return Icons.stop;
      case GameType.borderless:
        return Icons.all_out;
      case GameType.portal:
        return Icons.compare_arrows;
    }
  }
}
