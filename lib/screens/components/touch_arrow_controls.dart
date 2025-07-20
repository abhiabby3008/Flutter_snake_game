import 'package:flutter/material.dart';
import 'package:flutter_snake/constans/theme_constants.dart';
import 'package:flutter_snake/screens/components/snake_joystick.dart';

class TouchArrowControls extends StatefulWidget {
  final void Function(StickDirection dir) onDirectionChanged;
  const TouchArrowControls({super.key, required this.onDirectionChanged});

  @override
  _TouchArrowControlsState createState() => _TouchArrowControlsState();
}

class _TouchArrowControlsState extends State<TouchArrowControls> {
  StickDirection? _pressedDirection;

  void _onDirectionPressed(StickDirection direction) {
    setState(() {
      _pressedDirection = direction;
    });
    widget.onDirectionChanged(direction);
  }

  void _onDirectionReleased() {
    setState(() {
      _pressedDirection = null;
    });
  }

  Widget _buildArrowButton({
    required StickDirection direction,
    required IconData icon,
    required Alignment alignment,
  }) {
    final isPressed = _pressedDirection == direction;
    
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: GestureDetector(
          onTapDown: (_) => _onDirectionPressed(direction),
          onTapUp: (_) => _onDirectionReleased(),
          onTapCancel: _onDirectionReleased,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isPressed 
                  ? ThemeConstants.foodColor.withOpacity(0.8)
                  : ThemeConstants.joyStickColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isPressed 
                    ? ThemeConstants.foodColor 
                    : Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isPressed ? Colors.white : Colors.black,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          // Up arrow
          _buildArrowButton(
            direction: StickDirection.up,
            icon: Icons.keyboard_arrow_up,
            alignment: Alignment.topCenter,
          ),
          // Down arrow
          _buildArrowButton(
            direction: StickDirection.down,
            icon: Icons.keyboard_arrow_down,
            alignment: Alignment.bottomCenter,
          ),
          // Left arrow
          _buildArrowButton(
            direction: StickDirection.left,
            icon: Icons.keyboard_arrow_left,
            alignment: Alignment.centerLeft,
          ),
          // Right arrow
          _buildArrowButton(
            direction: StickDirection.right,
            icon: Icons.keyboard_arrow_right,
            alignment: Alignment.centerRight,
          ),
        ],
      ),
    );
  }
}