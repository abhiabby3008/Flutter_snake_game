import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_snake/constans/theme_constants.dart';
import 'package:flutter_snake/screens/components/global_text.dart';

class CountdownWidget extends StatefulWidget {
  final VoidCallback onCountdownComplete;
  final String? title;
  final bool showResumeButton;
  final VoidCallback? onCancel;

  const CountdownWidget({
    Key? key,
    required this.onCountdownComplete,
    this.title,
    this.showResumeButton = false,
    this.onCancel,
  }) : super(key: key);

  @override
  _CountdownWidgetState createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget>
    with TickerProviderStateMixin {
  int _currentCount = 3;
  Timer? _countdownTimer;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _showResumeButton = false;
  bool _countdownActive = false;

  @override
  void initState() {
    super.initState();
    _showResumeButton = widget.showResumeButton;
    _setupAnimations();

    if (!widget.showResumeButton) {
      // For initial countdown, start immediately
      _startCountdown();
    }
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
  }

  void _startCountdown() {
    setState(() {
      _showResumeButton = false;
      _countdownActive = true;
      _currentCount = 3;
    });

    // Show first number immediately
    _playCountdownAnimation();

    // Start timer for subsequent numbers
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentCount > 1) {
        setState(() {
          _currentCount--;
        });
        _playCountdownAnimation();
      } else {
        // Countdown finished
        timer.cancel();
        // Add a small delay before completing
        Timer(const Duration(milliseconds: 800), () {
          if (mounted) {
            widget.onCountdownComplete();
          }
        });
      }
    });
  }

  void _playCountdownAnimation() {
    HapticFeedback.mediumImpact();
    // Reset both controllers
    _scaleController.reset();
    _fadeController.reset();
    
    // Start fade in immediately
    _fadeController.forward();
    // Start scale animation
    _scaleController.forward();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title (Get Ready, Game Paused, etc.)
            if (widget.title != null) ...[
              GlobalText(
                text: widget.title!,
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: "Pixelify Sans",
              ),
              const SizedBox(height: 40),
            ],

            // Resume button (only show when needed and countdown not active)
            if (_showResumeButton && !_countdownActive) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: ThemeConstants.snakeColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _startCountdown();
                  },
                  child: const GlobalText(
                    text: 'Resume Gameplay',
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Pixelify Sans",
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (widget.onCancel != null)
                TextButton(
                  onPressed: widget.onCancel,
                  child: const GlobalText(
                    text: 'Cancel',
                    fontSize: 16,
                    color: Colors.white70,
                    fontFamily: "Pixelify Sans",
                  ),
                ),
            ],

            // Countdown numbers (show when countdown is active)
            if (_countdownActive) ...[
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value, // Fixed: use direct value
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ThemeConstants.snakeColor,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeConstants.snakeColor
                                      .withOpacity(0.6),
                                  blurRadius: 25,
                                  spreadRadius: 8,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: GlobalText(
                                text: _currentCount.toString(),
                                fontSize: 56,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Pixelify Sans",
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
