import 'package:flutter_snake/screens/components/snake_joystick.dart';

enum DifficultyLevel {
  easy,
  medium,
  hard,
}

enum GameType {
  classic,
  borderless,
  portal,
}

class GameSettings {
  final ControlType controlType;
  final DifficultyLevel difficulty;
  final GameType gameType;

  const GameSettings({
    this.controlType = ControlType.joystick,
    this.difficulty = DifficultyLevel.medium,
    this.gameType = GameType.classic,
  });

  GameSettings copyWith({
    ControlType? controlType,
    DifficultyLevel? difficulty,
    GameType? gameType,
  }) {
    return GameSettings(
      controlType: controlType ?? this.controlType,
      difficulty: difficulty ?? this.difficulty,
      gameType: gameType ?? this.gameType,
    );
  }

  // Speed settings based on difficulty
  Duration get maxTick {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return const Duration(milliseconds: 400);
      case DifficultyLevel.medium:
        return const Duration(milliseconds: 300);
      case DifficultyLevel.hard:
        return const Duration(milliseconds: 200);
    }
  }

  Duration get minTick {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return const Duration(milliseconds: 150);
      case DifficultyLevel.medium:
        return const Duration(milliseconds: 100);
      case DifficultyLevel.hard:
        return const Duration(milliseconds: 50);
    }
  }

  String get difficultyName {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
    }
  }

  String get gameTypeName {
    switch (gameType) {
      case GameType.classic:
        return 'Classic';
      case GameType.borderless:
        return 'Borderless';
      case GameType.portal:
        return 'Portal';
    }
  }

  String get gameTypeDescription {
    switch (gameType) {
      case GameType.classic:
        return 'Hit walls = Game Over';
      case GameType.borderless:
        return 'Wrap around edges';
      case GameType.portal:
        return 'Teleport through walls';
    }
  }
}