import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/mood_entry.dart';
import 'encryption_service.dart';

class MoodStorage {
  static const String _keyMoodEntries = 'mood_entries';
  static const String _keyMoodEntriesHash = 'mood_entries_hash';

  static Future<List<MoodEntry>> loadMoodEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encryptedEntriesJson = prefs.getString(_keyMoodEntries);
      final String? storedHash = prefs.getString(_keyMoodEntriesHash);
      
      if (encryptedEntriesJson != null) {
        // Decrypt the data
        final String entriesJson = EncryptionService.decrypt(encryptedEntriesJson);
        
        // Verify data integrity if hash exists
        if (storedHash != null) {
          if (!EncryptionService.verifyDataIntegrity(entriesJson, storedHash)) {
            throw Exception('Data integrity check failed - possible data corruption');
          }
        }
        
        final List<dynamic> entriesList = json.decode(entriesJson);
        final entries = entriesList.map((entry) => MoodEntry.fromJson(entry)).toList();
        entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return entries;
      }
    } catch (e) {
      // Log error and return empty list to prevent app crash
      print('Error loading mood entries: $e');
      // In production, you would log this to your crash reporting service
    }
    
    return [];
  }

  static Future<void> saveMoodEntries(List<MoodEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String entriesJson = json.encode(entries.map((entry) => entry.toJson()).toList());
      
      // Create data hash for integrity verification
      final String dataHash = EncryptionService.hashData(entriesJson);
      
      // Encrypt the data
      final String encryptedEntriesJson = EncryptionService.encrypt(entriesJson);
      
      // Store encrypted data and hash
      await prefs.setString(_keyMoodEntries, encryptedEntriesJson);
      await prefs.setString(_keyMoodEntriesHash, dataHash);
    } catch (e) {
      // Log error but don't prevent app functionality
      print('Error saving mood entries: $e');
      // In production, you would log this to your crash reporting service
      rethrow; // Re-throw to let calling code handle the error
    }
  }

  /// Clear all mood entries (secure deletion)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMoodEntries);
    await prefs.remove(_keyMoodEntriesHash);
  }

  /// Backup mood entries to external storage (encrypted)
  static Future<String> createBackup(List<MoodEntry> entries) async {
    final String entriesJson = json.encode(entries.map((entry) => entry.toJson()).toList());
    
    // Create backup with timestamp and encryption
    final backup = {
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'data': entriesJson,
      'hash': EncryptionService.hashData(entriesJson),
    };
    
    final String backupJson = json.encode(backup);
    return EncryptionService.encrypt(backupJson);
  }

  /// Restore mood entries from backup
  static Future<List<MoodEntry>> restoreFromBackup(String encryptedBackup) async {
    try {
      // Decrypt backup
      final String backupJson = EncryptionService.decrypt(encryptedBackup);
      final Map<String, dynamic> backup = json.decode(backupJson);
      
      // Verify backup format
      if (!backup.containsKey('data') || !backup.containsKey('hash')) {
        throw Exception('Invalid backup format');
      }
      
      final String entriesJson = backup['data'];
      final String expectedHash = backup['hash'];
      
      // Verify data integrity
      if (!EncryptionService.verifyDataIntegrity(entriesJson, expectedHash)) {
        throw Exception('Backup data integrity check failed');
      }
      
      // Parse entries
      final List<dynamic> entriesList = json.decode(entriesJson);
      final entries = entriesList.map((entry) => MoodEntry.fromJson(entry)).toList();
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return entries;
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }
}
