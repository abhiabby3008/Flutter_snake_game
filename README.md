# Flutter Snake Game

A classic Snake game built with Flutter featuring retro aesthetics, multiple control options, and comprehensive game settings. The game includes persistent high score tracking, customizable difficulty levels, and various game modes.

## Features

### Game Modes
- **Classic**: Traditional snake game with boundaries
- **Borderless**: Snake wraps around screen edges
- **Portal**: Advanced movement with portal mechanics

### Control Options
- **Joystick**: Virtual joystick control
- **Touch Arrows**: Directional arrow buttons
- **Swipe**: Gesture-based controls

### Difficulty Levels
- **Easy**: Slower pace for beginners
- **Medium**: Balanced gameplay
- **Hard**: Fast-paced challenge
- **Expert**: Maximum difficulty

### Game Features
- **High Score Tracking**: Persistent storage of best scores
- **Restart Functionality**: In-game restart with confirmation dialog
- **Settings Integration**: Accessible from multiple screens
- **Pause/Resume**: Game state management
- **Retro UI**: Consistent dark theme with accent colors
- **Responsive Design**: Optimized for various screen sizes

## Project Structure

- `lib/main.dart`: Application entry point
- `lib/screens/on_board_screen.dart`: Welcome screen with high score display
- `lib/screens/game_screen.dart`: Main gameplay with restart functionality
- `lib/screens/game_over_screen.dart`: End game screen with settings access
- `lib/screens/settings_screen.dart`: Comprehensive game configuration
- `lib/models/game_settings.dart`: Game configuration data models
- `lib/services/score_manager.dart`: High score persistence service
- `lib/constans/theme_constants.dart`: UI theme and color definitions
- `lib/screens/components/`: Reusable UI components

## Dependencies

- `flutter_joystick`: Virtual joystick controls
- `google_fonts`: Custom typography (Pixelify Sans)
- `shared_preferences`: Local data persistence
- `cupertino_icons`: iOS-style icons

## Getting Started

To run this project locally, ensure you have Flutter installed.

1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/flutter_snake.git
   cd flutter_snake