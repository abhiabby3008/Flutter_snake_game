import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ScoreManager {
  static const String _highScoreKey = 'high_score';
  static const String _currentScoreKey = 'current_score';

  static ScoreManager? _instance;
  static ScoreManager get instance => _instance ??= ScoreManager._();

  ScoreManager._();

  // In-memory fallback for when SharedPreferences fails
  int _fallbackCurrentScore = 0;
  int _fallbackHighScore = 0;
  bool _useInMemoryFallback = false;

  // Helper method to get SharedPreferences with error handling
  Future<SharedPreferences?> _getPrefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (e) {
      if (kDebugMode) {
        print('SharedPreferences error: $e');
        print('Falling back to in-memory storage');
      }
      _useInMemoryFallback = true;
      return null;
    }
  }

  // Save current score
  Future<void> saveCurrentScore(int score) async {
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.setInt(_currentScoreKey, score);
      } else {
        _fallbackCurrentScore = score;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving current score: $e');
      }
      _fallbackCurrentScore = score;
    }
  }

  // Get current score
  Future<int> getCurrentScore() async {
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        return prefs.getInt(_currentScoreKey) ?? 0;
      } else {
        return _fallbackCurrentScore;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current score: $e');
      }
      return _fallbackCurrentScore;
    }
  }

  // Save high score (only if it's higher than current high score)
  Future<bool> saveHighScore(int score) async {
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        final currentHighScore = prefs.getInt(_highScoreKey) ?? 0;

        if (score > currentHighScore) {
          await prefs.setInt(_highScoreKey, score);
          return true; // New high score!
        }
        return false; // Not a new high score
      } else {
        // Fallback to in-memory storage
        if (score > _fallbackHighScore) {
          _fallbackHighScore = score;
          return true;
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving high score: $e');
      }
      // Fallback to in-memory storage
      if (score > _fallbackHighScore) {
        _fallbackHighScore = score;
        return true;
      }
      return false;
    }
  }

  // Get high score
  Future<int> getHighScore() async {
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        return prefs.getInt(_highScoreKey) ?? 0;
      } else {
        return _fallbackHighScore;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting high score: $e');
      }
      return _fallbackHighScore;
    }
  }

  // Clear all scores (for testing or reset functionality)
  Future<void> clearScores() async {
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.remove(_highScoreKey);
        await prefs.remove(_currentScoreKey);
      }
      // Also clear fallback values
      _fallbackCurrentScore = 0;
      _fallbackHighScore = 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing scores: $e');
      }
      // Clear fallback values
      _fallbackCurrentScore = 0;
      _fallbackHighScore = 0;
    }
  }

  // Check if using fallback storage
  bool get isUsingFallback => _useInMemoryFallback;
}
