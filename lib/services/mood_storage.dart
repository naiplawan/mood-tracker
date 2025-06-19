import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/mood_entry.dart';

class MoodStorage {
  static const String _keyMoodEntries = 'mood_entries';

  static Future<List<MoodEntry>> loadMoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJson = prefs.getString(_keyMoodEntries);
    
    if (entriesJson != null) {
      final List<dynamic> entriesList = json.decode(entriesJson);
      final entries = entriesList.map((entry) => MoodEntry.fromJson(entry)).toList();
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return entries;
    }
    
    return [];
  }

  static Future<void> saveMoodEntries(List<MoodEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final String entriesJson = json.encode(entries.map((entry) => entry.toJson()).toList());
    await prefs.setString(_keyMoodEntries, entriesJson);
  }
}
