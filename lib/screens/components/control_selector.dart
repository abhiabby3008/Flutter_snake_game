import 'package:flutter/material.dart';
import 'package:flutter_snake/constans/theme_constants.dart';
import 'package:flutter_snake/screens/components/global_text.dart';
import 'package:flutter_snake/screens/components/snake_joystick.dart';

class ControlSelector extends StatelessWidget {
  final ControlType currentControlType;
  final void Function(ControlType) onControlTypeChanged;

  const ControlSelector({
    super.key,
    required this.currentControlType,
    required this.onControlTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ThemeConstants.joyStickColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black26),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlOption(
            controlType: ControlType.joystick,
            icon: Icons.radio_button_unchecked,
            label: 'Stick',
          ),
          const SizedBox(width: 8),
          _buildControlOption(
            controlType: ControlType.touchArrows,
            icon: Icons.keyboard_arrow_up,
            label: 'Arrows',
          ),
          const SizedBox(width: 8),
          _buildControlOption(
            controlType: ControlType.swipe,
            icon: Icons.swipe,
            label: 'Swipe',
          ),
        ],
      ),
    );
  }

  Widget _buildControlOption({
    required ControlType controlType,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentControlType == controlType;

    return GestureDetector(
      onTap: () => onControlTypeChanged(controlType),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? ThemeConstants.foodColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 2),
            GlobalText(
              fontSize: 10,
              text: label,
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ],
        ),
      ),
    );
  }
}
