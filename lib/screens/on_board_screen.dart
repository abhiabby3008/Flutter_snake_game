import 'package:flutter/material.dart';
import 'package:flutter_snake/constans/theme_constants.dart';
import 'package:flutter_snake/screens/components/global_text.dart';
import 'package:flutter_snake/screens/game_screen.dart';

class OnBoardScreen extends StatelessWidget {
  const OnBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeConstants.gameOverColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: GlobalText(
                fontSize: 40,
                text: "Start Game",
                fontFamily: "Pixelify Sans",
                color: ThemeConstants.textColorWhite,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GameScreen()));
              },
              child: const Icon(
                Icons.play_arrow,
                size: 50,
                color: Colors.white,
              ),
            )
          ],
        ));
  }
}
