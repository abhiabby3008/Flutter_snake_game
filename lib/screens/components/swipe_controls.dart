import 'package:flutter/material.dart';
import 'package:flutter_snake/constans/theme_constants.dart';
import 'package:flutter_snake/screens/components/snake_joystick.dart';
import 'package:flutter_snake/screens/components/global_text.dart';

class SwipeControls extends StatefulWidget {
  final void Function(StickDirection dir) onDirectionChanged;
  final StickDirection? lastSwipeDirection;
  
  const SwipeControls({
    Key? key, 
    required this.onDirectionChanged,
    this.lastSwipeDirection,
  }) : super(key: key);

  @override
  _SwipeControlsState createState() => _SwipeControlsState();
}

class _SwipeControlsState extends State<SwipeControls>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start subtle pulsing animation
    _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(SwipeControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastSwipeDirection != null && 
        widget.lastSwipeDirection != oldWidget.lastSwipeDirection) {
      _triggerSwipeEffect();
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerSwipeEffect() {
    _rippleController.forward().then((_) {
      _rippleController.reset();
    });
  }

  IconData _getDirectionIcon(StickDirection direction) {
    switch (direction) {
      case StickDirection.up:
        return Icons.keyboard_arrow_up;
      case StickDirection.down:
        return Icons.keyboard_arrow_down;
      case StickDirection.left:
        return Icons.keyboard_arrow_left;
      case StickDirection.right:
        return Icons.keyboard_arrow_right;
      default:
        return Icons.touch_app;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: ThemeConstants.joyStickColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ThemeConstants.joyStickColor.withOpacity(0.6),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Background pattern with swipe indicators
                Center(
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: ThemeConstants.joyStickColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Stack(
                      children: [
                        // Center content
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.swipe,
                                size: 32,
                                color: Colors.black45,
                              ),
                              SizedBox(height: 4),
                              GlobalText(
                                fontSize: 10,
                                text: 'Swipe anywhere',
                                color: Colors.black45,
                              ),
                            ],
                          ),
                        ),
                        // Directional indicators
                        Positioned(
                          top: 10,
                          left: 0,
                          right: 0,
                          child: Icon(
                            Icons.keyboard_arrow_up,
                            size: 20,
                            color: Colors.black26,
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 20,
                            color: Colors.black26,
                          ),
                        ),
                        Positioned(
                          left: 10,
                          top: 0,
                          bottom: 0,
                          child: Icon(
                            Icons.keyboard_arrow_left,
                            size: 20,
                            color: Colors.black26,
                          ),
                        ),
                        Positioned(
                          right: 10,
                          top: 0,
                          bottom: 0,
                          child: Icon(
                            Icons.keyboard_arrow_right,
                            size: 20,
                            color: Colors.black26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Ripple effect for swipe feedback
                if (widget.lastSwipeDirection != null)
                  AnimatedBuilder(
                    animation: _rippleAnimation,
                    builder: (context, child) {
                      return Center(
                        child: Container(
                          width: 200 * _rippleAnimation.value,
                          height: 200 * _rippleAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ThemeConstants.foodColor.withOpacity(
                                (1.0 - _rippleAnimation.value) * 0.8,
                              ),
                              width: 4,
                            ),
                          ),
                          child: _rippleAnimation.value > 0.2
                              ? Icon(
                                  _getDirectionIcon(widget.lastSwipeDirection!),
                                  size: 80 * _rippleAnimation.value,
                                  color: ThemeConstants.foodColor.withOpacity(
                                    (1.0 - _rippleAnimation.value) * 0.9,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
