// lib/screens/game_over_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_snake/constans/theme_constants.dart';
import 'package:flutter_snake/screens/components/global_text.dart';
import 'package:flutter_snake/screens/game_screen.dart';

class GameOverScreen extends StatelessWidget {
  final int score;
  const GameOverScreen({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.gameOverColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              text: score.toString().padLeft(5, '0'),
              fontSize: 30,
              fontFamily: "Pixelify Sans",
              color: ThemeConstants.foodColor,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                // restart by popping back to the GameScreen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                );
              },
              child: const Icon(
                Icons.restore,
                size: 40,
                color: ThemeConstants.textColorWhite,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const GlobalText(
              fontSize: 20,
              text: 'Play Again',
              color: ThemeConstants.textColorWhite,
            )
          ],
        ),
      ),
    );
  }
}
