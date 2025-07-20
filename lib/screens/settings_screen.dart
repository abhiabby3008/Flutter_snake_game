import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_snake/constans/theme_constants.dart';
import 'package:flutter_snake/screens/components/global_text.dart';
import 'package:flutter_snake/screens/components/snake_joystick.dart';
import 'package:flutter_snake/models/game_settings.dart';

class SettingsScreen extends StatefulWidget {
  final GameSettings currentSettings;
  final void Function(GameSettings) onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.currentSettings,
    required this.onSettingsChanged,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late GameSettings _settings;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _settings = widget.currentSettings;
  }

  void _updateSettings(GameSettings newSettings) {
    setState(() {
      _settings = newSettings;
      _hasChanges = true;
    });
    HapticFeedback.selectionClick();
  }

  void _saveSettings() {
    Navigator.of(context).pop(_settings);
    HapticFeedback.mediumImpact();
  }

  void _discardChanges() {
    Navigator.of(context).pop(widget.currentSettings);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context)
            .pop(_hasChanges ? _settings : widget.currentSettings);
        return false;
      },
      child: Scaffold(
        backgroundColor: ThemeConstants.gameOverColor,
        appBar: AppBar(
          backgroundColor: ThemeConstants.gameOverColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context)
                .pop(_hasChanges ? _settings : widget.currentSettings),
          ),
          title: const GlobalText(
            fontSize: 24,
            text: 'Settings',
            fontWeight: FontWeight.bold,
            fontFamily: "Pixelify Sans",
            color: ThemeConstants.textColorWhite,
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Controls'),
                    const SizedBox(height: 16),
                    _buildControlsSection(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Difficulty'),
                    const SizedBox(height: 16),
                    _buildDifficultySection(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Game Type'),
                    const SizedBox(height: 16),
                    _buildGameTypeSection(),
                    const SizedBox(height: 100), // Space for save button
                  ],
                ),
              ),
            ),
            // Save button at bottom
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeConstants.gameOverColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_hasChanges)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _discardChanges,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side:
                              BorderSide(color: Colors.white.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const GlobalText(
                          fontSize: 16,
                          text: 'Discard',
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  if (_hasChanges) const SizedBox(width: 12),
                  Expanded(
                    flex: _hasChanges ? 2 : 1,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConstants.foodColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: GlobalText(
                        fontSize: 16,
                        text: _hasChanges ? 'Save Changes' : 'Done',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return GlobalText(
      fontSize: 20,
      text: title,
      fontWeight: FontWeight.bold,
      color: ThemeConstants.textColorWhite,
    );
  }

  Widget _buildControlsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildControlOption(
            controlType: ControlType.joystick,
            icon: Icons.radio_button_unchecked,
            title: 'Joystick',
            description: 'Virtual joystick control',
          ),
          const SizedBox(height: 12),
          _buildControlOption(
            controlType: ControlType.touchArrows,
            icon: Icons.keyboard_arrow_up,
            title: 'Touch Arrows',
            description: 'Directional button controls',
          ),
          const SizedBox(height: 12),
          _buildControlOption(
            controlType: ControlType.swipe,
            icon: Icons.swipe,
            title: 'Swipe',
            description: 'Swipe anywhere on screen',
          ),
        ],
      ),
    );
  }

  Widget _buildControlOption({
    required ControlType controlType,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _settings.controlType == controlType;

    return GestureDetector(
      onTap: () =>
          _updateSettings(_settings.copyWith(controlType: controlType)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeConstants.foodColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? ThemeConstants.foodColor
                : Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? ThemeConstants.foodColor : Colors.white70,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlobalText(
                    fontSize: 16,
                    text: title,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? ThemeConstants.foodColor : Colors.white,
                  ),
                  GlobalText(
                    fontSize: 12,
                    text: description,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: ThemeConstants.foodColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildDifficultyOption(
            difficulty: DifficultyLevel.easy,
            icon: Icons.sentiment_satisfied,
            description: 'Slow speed, relaxed gameplay',
          ),
          const SizedBox(height: 12),
          _buildDifficultyOption(
            difficulty: DifficultyLevel.medium,
            icon: Icons.sentiment_neutral,
            description: 'Moderate speed, balanced challenge',
          ),
          const SizedBox(height: 12),
          _buildDifficultyOption(
            difficulty: DifficultyLevel.hard,
            icon: Icons.sentiment_very_dissatisfied,
            description: 'Fast speed, intense gameplay',
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyOption({
    required DifficultyLevel difficulty,
    required IconData icon,
    required String description,
  }) {
    final isSelected = _settings.difficulty == difficulty;

    return GestureDetector(
      onTap: () => _updateSettings(_settings.copyWith(difficulty: difficulty)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeConstants.foodColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? ThemeConstants.foodColor
                : Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? ThemeConstants.foodColor : Colors.white70,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlobalText(
                    fontSize: 16,
                    text: GameSettings(difficulty: difficulty).difficultyName,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? ThemeConstants.foodColor : Colors.white,
                  ),
                  GlobalText(
                    fontSize: 12,
                    text: description,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: ThemeConstants.foodColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTypeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildGameTypeOption(
            gameType: GameType.classic,
            icon: Icons.stop,
            description: 'Traditional snake - walls end the game',
          ),
          const SizedBox(height: 12),
          _buildGameTypeOption(
            gameType: GameType.borderless,
            icon: Icons.all_out,
            description: 'Snake wraps around screen edges',
          ),
          const SizedBox(height: 12),
          _buildGameTypeOption(
            gameType: GameType.portal,
            icon: Icons.compare_arrows,
            description: 'Teleport through walls to opposite side',
          ),
        ],
      ),
    );
  }

  Widget _buildGameTypeOption({
    required GameType gameType,
    required IconData icon,
    required String description,
  }) {
    final isSelected = _settings.gameType == gameType;

    return GestureDetector(
      onTap: () => _updateSettings(_settings.copyWith(gameType: gameType)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeConstants.foodColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? ThemeConstants.foodColor
                : Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? ThemeConstants.foodColor : Colors.white70,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlobalText(
                    fontSize: 16,
                    text: GameSettings(gameType: gameType).gameTypeName,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? ThemeConstants.foodColor : Colors.white,
                  ),
                  GlobalText(
                    fontSize: 12,
                    text: description,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: ThemeConstants.foodColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
