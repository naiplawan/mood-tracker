import 'package:flutter/material.dart';

class MoodData {
  static const List<Map<String, String>> moods = [
    {'name': 'Fantastic', 'emoji': '🤩', 'color': '0xFF10B981'},
    {'name': 'Happy', 'emoji': '😄', 'color': '0xFF22C55E'},
    {'name': 'Good', 'emoji': '😊', 'color': '0xFF84CC16'},
    {'name': 'Content', 'emoji': '😐', 'color': '0xFFEAB308'},
    {'name': 'Neutral', 'emoji': '😐', 'color': '0xFF6B7280'},
    {'name': 'Tired', 'emoji': '😐', 'color': '0xFF8B5CF6'},
    {'name': 'Anxious', 'emoji': '😰', 'color': '0xFFF59E0B'},
    {'name': 'Sad', 'emoji': '😢', 'color': '0xFF3B82F6'},
    {'name': 'Angry', 'emoji': '😐', 'color': '0xFFEF4444'},
    {'name': 'Stressed', 'emoji': '😫', 'color': '0xFFDC2626'},
  ];

  static Color getMoodColor(String mood) {
    final moodData = moods.firstWhere(
      (m) => m['name'] == mood, 
      orElse: () => {'color': '0xFF6B7280'}
    );
    return Color(int.parse(moodData['color']!));
  }

  static String getMoodEmoji(String mood) {
    final moodData = moods.firstWhere(
      (m) => m['name'] == mood, 
      orElse: () => {'emoji': '😐'}
    );
    return moodData['emoji']!;
  }
}
