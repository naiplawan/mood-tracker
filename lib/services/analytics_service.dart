import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../constants/mood_data.dart';

class AnalyticsService {
  static Map<String, int> getMoodFrequency(List<MoodEntry> entries) {
    final Map<String, int> frequency = {};
    
    for (final entry in entries) {
      frequency[entry.mood] = (frequency[entry.mood] ?? 0) + 1;
    }
    
    return frequency;
  }

  static List<MoodEntry> getEntriesForLastDays(List<MoodEntry> entries, int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return entries.where((entry) => entry.timestamp.isAfter(cutoffDate)).toList();
  }

  static List<FlSpot> getMoodTrendData(List<MoodEntry> entries, int days) {
    final recentEntries = getEntriesForLastDays(entries, days);
    final Map<String, List<int>> dailyMoods = {};
    
    // Group entries by date
    for (final entry in recentEntries) {
      final dateKey = "${entry.timestamp.year}-${entry.timestamp.month}-${entry.timestamp.day}";
      dailyMoods.putIfAbsent(dateKey, () => []);
      
      // Convert mood to numeric value (1-5 scale)
      final moodValue = _getMoodValue(entry.mood);
      dailyMoods[dateKey]!.add(moodValue);
    }
    
    // Calculate average mood per day
    final List<FlSpot> spots = [];
    final sortedDates = dailyMoods.keys.toList()..sort();
    
    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final moods = dailyMoods[date]!;
      final averageMood = moods.reduce((a, b) => a + b) / moods.length;
      spots.add(FlSpot(i.toDouble(), averageMood));
    }
    
    return spots;
  }

  static int _getMoodValue(String mood) {
    // Convert mood names to numeric values for trending
    switch (mood.toLowerCase()) {
      case 'fantastic':
        return 5;
      case 'happy':
        return 4;
      case 'good':
        return 4;
      case 'content':
        return 3;
      case 'neutral':
        return 3;
      case 'tired':
        return 2;
      case 'anxious':
        return 2;
      case 'sad':
        return 1;
      case 'angry':
        return 1;
      case 'stressed':
        return 1;
      default:
        return 3;
    }
  }

  static List<PieChartSectionData> getMoodDistributionChart(List<MoodEntry> entries) {
    final frequency = getMoodFrequency(entries);
    final total = entries.length;
    
    if (total == 0) return [];
    
    return frequency.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = MoodData.getMoodColor(entry.key);
      
      return PieChartSectionData(
        color: color,
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  static Map<String, dynamic> getMoodInsights(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return {
        'totalEntries': 0,
        'averageMood': 'No data',
        'mostFrequentMood': 'No data',
        'streak': 0,
        'bestDay': 'No data',
        'worstDay': 'No data',
      };
    }

    final frequency = getMoodFrequency(entries);
    final mostFrequent = frequency.entries.reduce((a, b) => a.value > b.value ? a : b);
    
    // Calculate average mood value
    final totalMoodValue = entries.fold(0, (sum, entry) => sum + _getMoodValue(entry.mood));
    final averageMoodValue = totalMoodValue / entries.length;
    final averageMood = _getMoodNameFromValue(averageMoodValue.round());
    
    // Calculate current streak of positive moods
    int streak = 0;
    for (final entry in entries.reversed) {
      if (_getMoodValue(entry.mood) >= 3) {
        streak++;
      } else {
        break;
      }
    }

    return {
      'totalEntries': entries.length,
      'averageMood': averageMood,
      'mostFrequentMood': mostFrequent.key,
      'streak': streak,
      'bestDay': _getBestDay(entries),
      'worstDay': _getWorstDay(entries),
    };
  }

  static String _getMoodNameFromValue(int value) {
    switch (value) {
      case 5:
        return 'Fantastic';
      case 4:
        return 'Happy';
      case 3:
        return 'Content';
      case 2:
        return 'Tired';
      case 1:
        return 'Sad';
      default:
        return 'Content';
    }
  }

  static String _getBestDay(List<MoodEntry> entries) {
    if (entries.isEmpty) return 'No data';
    
    final bestEntry = entries.reduce((a, b) => 
      _getMoodValue(a.mood) > _getMoodValue(b.mood) ? a : b);
    
    return "${bestEntry.timestamp.day}/${bestEntry.timestamp.month}";
  }

  static String _getWorstDay(List<MoodEntry> entries) {
    if (entries.isEmpty) return 'No data';
    
    final worstEntry = entries.reduce((a, b) => 
      _getMoodValue(a.mood) < _getMoodValue(b.mood) ? a : b);
    
    return "${worstEntry.timestamp.day}/${worstEntry.timestamp.month}";
  }
}
