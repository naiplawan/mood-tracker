import 'package:flutter/material.dart';

class MoodData {
  static const List<Map<String, String>> moods = [
    {'name': 'Fantastic', 'emoji': '🌟', 'color': '0xFF6366F1'}, // Indigo
    {'name': 'Happy', 'emoji': '✨', 'color': '0xFF8B5CF6'}, // Purple
    {'name': 'Good', 'emoji': '💫', 'color': '0xFF3B82F6'}, // Blue
    {'name': 'Content', 'emoji': '🌙', 'color': '0xFF0EA5E9'}, // Light Blue
    {'name': 'Neutral', 'emoji': '⭐', 'color': '0xFF14B8A6'}, // Teal
    {'name': 'Tired', 'emoji': '🌌', 'color': '0xFF6B7280'}, // Cool Gray
    {'name': 'Anxious', 'emoji': '🌊', 'color': '0xFFEAB308'}, // Yellow
    {'name': 'Sad', 'emoji': '☁️', 'color': '0xFFF97316'}, // Orange
    {'name': 'Angry', 'emoji': '⚡', 'color': '0xFFEF4444'}, // Red
    {'name': 'Stressed', 'emoji': '🌪️', 'color': '0xFFDC2626'}, // Dark Red
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
      orElse: () => {'emoji': '⭐'}
    );
    return moodData['emoji']!;
  }

  static LinearGradient getMoodGradient(String mood) {
    final color = getMoodColor(mood);
    return LinearGradient(
      colors: [
        color,
        color.withOpacity(0.7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static List<BoxShadow> getMoodShadow(String mood) {
    final color = getMoodColor(mood);
    return [
      BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ];
  }
}
