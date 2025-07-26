import '../models/mood_entry.dart';
import 'database_service.dart';
import 'migration_service.dart';
import 'crash_reporting_service.dart';

/// Database-backed storage service for mood entries
class MoodDatabaseStorage {
  static bool _initialized = false;

  /// Initialize the database storage
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Ensure database is initialized
      await DatabaseService.database;
      
      // Perform migration if needed
      await MigrationService.performMigrationIfNeeded();
      
      _initialized = true;
      
      await CrashReportingService.logEvent('database_storage_initialized');
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Database storage initialization failed',
      );
      rethrow;
    }
  }

  /// Load all mood entries
  static Future<List<MoodEntry>> loadMoodEntries() async {
    try {
      await _ensureInitialized();
      return await DatabaseService.getAllMoodEntries();
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to load mood entries from database',
      );
      return [];
    }
  }

  /// Save a single mood entry
  static Future<void> saveMoodEntry(MoodEntry entry) async {
    try {
      await _ensureInitialized();
      await DatabaseService.insertMoodEntry(entry);
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to save mood entry to database',
        additionalData: {'entry_id': entry.id},
      );
      rethrow;
    }
  }

  /// Save multiple mood entries (batch operation)
  static Future<void> saveMoodEntries(List<MoodEntry> entries) async {
    try {
      await _ensureInitialized();
      
      // Use transaction for batch operations
      final db = await DatabaseService.database;
      await db.transaction((txn) async {
        for (final entry in entries) {
          await DatabaseService.insertMoodEntry(entry);
        }
      });
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to save mood entries batch to database',
        additionalData: {'entries_count': entries.length},
      );
      rethrow;
    }
  }

  /// Delete a mood entry
  static Future<void> deleteMoodEntry(String entryId) async {
    try {
      await _ensureInitialized();
      await DatabaseService.deleteMoodEntry(entryId);
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to delete mood entry from database',
        additionalData: {'entry_id': entryId},
      );
      rethrow;
    }
  }

  /// Clear all mood entries
  static Future<void> clearAllData() async {
    try {
      await _ensureInitialized();
      await DatabaseService.deleteAllMoodEntries();
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to clear all mood entries from database',
      );
      rethrow;
    }
  }

  /// Get mood entries for a specific date range
  static Future<List<MoodEntry>> getMoodEntriesInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      await _ensureInitialized();
      return await DatabaseService.getMoodEntriesInRange(startDate, endDate);
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to get mood entries in date range',
        additionalData: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
      return [];
    }
  }

  /// Create backup of all mood entries
  static Future<String> createBackup() async {
    try {
      await _ensureInitialized();
      return await DatabaseService.createDatabaseBackup();
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to create database backup',
      );
      rethrow;
    }
  }

  /// Restore mood entries from backup
  static Future<void> restoreFromBackup(String encryptedBackup) async {
    try {
      await _ensureInitialized();
      
      // This would need to be implemented in DatabaseService
      // For now, we'll use the old MoodStorage method as fallback
      throw UnimplementedError('Database backup restoration not yet implemented');
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to restore from database backup',
      );
      rethrow;
    }
  }

  /// Get storage statistics
  static Future<Map<String, dynamic>> getStorageStats() async {
    try {
      await _ensureInitialized();
      final dbStats = await DatabaseService.getDatabaseStats();
      final migrationStats = await MigrationService.getMigrationStats();
      
      return {
        'database_stats': dbStats,
        'migration_stats': migrationStats,
        'storage_type': 'sqlite',
        'initialized': _initialized,
      };
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to get storage statistics',
      );
      return {
        'error': e.toString(),
        'storage_type': 'sqlite',
        'initialized': _initialized,
      };
    }
  }

  /// Perform database maintenance
  static Future<void> performMaintenance() async {
    try {
      await _ensureInitialized();
      
      // Get database instance
      final db = await DatabaseService.database;
      
      // Analyze database for optimization
      await db.execute('ANALYZE');
      
      // Vacuum database to reclaim space
      await db.execute('VACUUM');
      
      // Update statistics
      await db.execute('PRAGMA optimize');
      
      await CrashReportingService.logEvent('database_maintenance_completed');
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Database maintenance failed',
      );
    }
  }

  /// Check database health
  static Future<Map<String, dynamic>> checkDatabaseHealth() async {
    try {
      await _ensureInitialized();
      
      final db = await DatabaseService.database;
      
      // Check database integrity
      final integrityResult = await db.rawQuery('PRAGMA integrity_check');
      final isHealthy = integrityResult.isNotEmpty && 
                       integrityResult.first.values.first == 'ok';
      
      // Get database size
      final dbPath = db.path;
      
      return {
        'healthy': isHealthy,
        'integrity_check': integrityResult,
        'database_path': dbPath,
        'last_check': DateTime.now().toIso8601String(),
      };
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Database health check failed',
      );
      return {
        'healthy': false,
        'error': e.toString(),
        'last_check': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Ensure the storage is initialized
  static Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// Close database connection
  static Future<void> close() async {
    await DatabaseService.closeDatabase();
    _initialized = false;
  }
}