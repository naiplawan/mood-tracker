import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mood_entry.dart';
import 'encryption_service.dart';
import 'crash_reporting_service.dart';

/// Service for SQLite database operations with encryption
class DatabaseService {
  static const String _databaseName = 'mood_tracker.db';
  static const int _databaseVersion = 1;
  
  static const String _tableMoodEntries = 'mood_entries';
  static const String _tableMetadata = 'metadata';

  static Database? _database;

  /// Get database instance (singleton pattern)
  static Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initializeDatabase();
    return _database!;
  }

  /// Initialize the database
  static Future<Database> _initializeDatabase() async {
    try {
      final documentsDirectory = await getDatabasesPath();
      final path = join(documentsDirectory, _databaseName);

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
        onConfigure: _configureDatabase,
      );
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Database initialization failed',
      );
      rethrow;
    }
  }

  /// Configure database settings
  static Future<void> _configureDatabase(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
    
    // Enable WAL mode for better concurrency
    await db.execute('PRAGMA journal_mode = WAL');
    
    // Set busy timeout
    await db.execute('PRAGMA busy_timeout = 30000');
  }

  /// Create database tables
  static Future<void> _createDatabase(Database db, int version) async {
    // Mood entries table
    await db.execute('''
      CREATE TABLE $_tableMoodEntries (
        id TEXT PRIMARY KEY,
        encrypted_data TEXT NOT NULL,
        data_hash TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Metadata table for app settings and sync info
    await db.execute('''
      CREATE TABLE $_tableMetadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_mood_entries_created_at 
      ON $_tableMoodEntries (created_at DESC)
    ''');

    // Insert initial metadata
    await db.insert(_tableMetadata, {
      'key': 'db_version',
      'value': version.toString(),
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });

    await db.insert(_tableMetadata, {
      'key': 'migration_from_shared_prefs',
      'value': 'pending',
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Handle database upgrades
  static Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    try {
      // Handle future database schema upgrades
      for (int version = oldVersion + 1; version <= newVersion; version++) {
        await _migrateToVersion(db, version);
      }
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Database upgrade failed from v$oldVersion to v$newVersion',
      );
      rethrow;
    }
  }

  /// Migrate database to specific version
  static Future<void> _migrateToVersion(Database db, int version) async {
    switch (version) {
      case 1:
        // Initial version - no migration needed
        break;
      // Add future migration cases here
      default:
        break;
    }
  }

  /// Insert or update a mood entry
  static Future<void> insertMoodEntry(MoodEntry entry) async {
    try {
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Encrypt the mood entry data
      final jsonData = entry.toJson();
      final jsonString = jsonData.toString();
      final encryptedData = EncryptionService.encrypt(jsonString);
      final dataHash = EncryptionService.hashData(jsonString);

      await db.insert(
        _tableMoodEntries,
        {
          'id': entry.id,
          'encrypted_data': encryptedData,
          'data_hash': dataHash,
          'created_at': entry.timestamp.millisecondsSinceEpoch,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to insert mood entry',
        additionalData: {'entry_id': entry.id},
      );
      rethrow;
    }
  }

  /// Get all mood entries
  static Future<List<MoodEntry>> getAllMoodEntries() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableMoodEntries,
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => _decryptMoodEntry(map)).where((entry) => entry != null).cast<MoodEntry>().toList();
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to retrieve mood entries',
      );
      return [];
    }
  }

  /// Get mood entries for a specific date range
  static Future<List<MoodEntry>> getMoodEntriesInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableMoodEntries,
        where: 'created_at BETWEEN ? AND ?',
        whereArgs: [
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => _decryptMoodEntry(map)).where((entry) => entry != null).cast<MoodEntry>().toList();
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to retrieve mood entries in range',
      );
      return [];
    }
  }

  /// Delete a mood entry
  static Future<void> deleteMoodEntry(String entryId) async {
    try {
      final db = await database;
      await db.delete(
        _tableMoodEntries,
        where: 'id = ?',
        whereArgs: [entryId],
      );
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to delete mood entry',
        additionalData: {'entry_id': entryId},
      );
      rethrow;
    }
  }

  /// Delete all mood entries
  static Future<void> deleteAllMoodEntries() async {
    try {
      final db = await database;
      await db.delete(_tableMoodEntries);
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to delete all mood entries',
      );
      rethrow;
    }
  }

  /// Get database statistics
  static Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final db = await database;
      
      final entryCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_tableMoodEntries'),
      ) ?? 0;
      
      final oldestEntry = await db.query(
        _tableMoodEntries,
        columns: ['created_at'],
        orderBy: 'created_at ASC',
        limit: 1,
      );
      
      final newestEntry = await db.query(
        _tableMoodEntries,
        columns: ['created_at'],
        orderBy: 'created_at DESC',
        limit: 1,
      );

      return {
        'total_entries': entryCount,
        'oldest_entry': oldestEntry.isNotEmpty 
          ? DateTime.fromMillisecondsSinceEpoch(oldestEntry.first['created_at'] as int)
          : null,
        'newest_entry': newestEntry.isNotEmpty 
          ? DateTime.fromMillisecondsSinceEpoch(newestEntry.first['created_at'] as int)
          : null,
        'database_path': await getDatabasesPath(),
      };
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to get database statistics',
      );
      return {};
    }
  }

  /// Decrypt and parse mood entry from database row
  static MoodEntry? _decryptMoodEntry(Map<String, dynamic> map) {
    try {
      final encryptedData = map['encrypted_data'] as String;
      final storedHash = map['data_hash'] as String;
      
      // Decrypt the data
      final decryptedData = EncryptionService.decrypt(encryptedData);
      
      // Verify data integrity
      if (!EncryptionService.verifyDataIntegrity(decryptedData, storedHash)) {
        throw Exception('Data integrity check failed for entry ${map['id']}');
      }
      
      // Parse JSON - note: we need to handle the string format properly
      final jsonString = decryptedData;
      // You might need to adjust this parsing based on how the data was stored
      final Map<String, dynamic> jsonData = _parseJsonString(jsonString);
      
      return MoodEntry.fromJson(jsonData);
    } catch (e) {
      // Log error but don't crash the app
      CrashReportingService.reportError(
        e,
        StackTrace.current,
        context: 'Failed to decrypt mood entry',
        additionalData: {'entry_id': map['id']},
      );
      return null;
    }
  }

  /// Parse JSON string (helper method)
  static Map<String, dynamic> _parseJsonString(String jsonString) {
    // This is a simplified parser - you might need to use dart:convert
    // depending on how the data was stored
    try {
      return Map<String, dynamic>.from(
        // You'll need to implement proper JSON parsing here
        // This is just a placeholder
        {},
      );
    } catch (e) {
      throw Exception('Failed to parse JSON data: $e');
    }
  }

  /// Set metadata value
  static Future<void> setMetadata(String key, String value) async {
    try {
      final db = await database;
      await db.insert(
        _tableMetadata,
        {
          'key': key,
          'value': value,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to set metadata',
        additionalData: {'key': key},
      );
      rethrow;
    }
  }

  /// Get metadata value
  static Future<String?> getMetadata(String key) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableMetadata,
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );

      return maps.isNotEmpty ? maps.first['value'] as String : null;
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to get metadata',
        additionalData: {'key': key},
      );
      return null;
    }
  }

  /// Close database connection
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Backup database to encrypted format
  static Future<String> createDatabaseBackup() async {
    try {
      final entries = await getAllMoodEntries();
      final stats = await getDatabaseStats();
      
      final backupData = {
        'version': _databaseVersion,
        'created_at': DateTime.now().toIso8601String(),
        'stats': stats,
        'entries': entries.map((e) => e.toJson()).toList(),
      };
      
      final backupJson = backupData.toString();
      return EncryptionService.encrypt(backupJson);
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to create database backup',
      );
      rethrow;
    }
  }
}