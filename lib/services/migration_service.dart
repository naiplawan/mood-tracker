import '../models/mood_entry.dart';
import 'mood_storage.dart';
import 'database_service.dart';
import 'crash_reporting_service.dart';

/// Service for migrating data from SharedPreferences to SQLite
class MigrationService {
  static const String _migrationKey = 'migration_from_shared_prefs';
  static const String _migrationCompleted = 'completed';
  static const String _migrationPending = 'pending';
  static const String _migrationFailed = 'failed';

  /// Check if migration is needed and perform it
  static Future<bool> performMigrationIfNeeded() async {
    try {
      // Check migration status
      final migrationStatus = await DatabaseService.getMetadata(_migrationKey);
      
      if (migrationStatus == _migrationCompleted) {
        // Migration already completed
        return true;
      }

      if (migrationStatus == _migrationFailed) {
        // Previous migration failed, retry
        await CrashReportingService.logEvent('migration_retry');
      }

      // Perform migration
      final success = await _migrateFromSharedPreferences();
      
      if (success) {
        await DatabaseService.setMetadata(_migrationKey, _migrationCompleted);
        await CrashReportingService.logEvent('migration_completed');
        return true;
      } else {
        await DatabaseService.setMetadata(_migrationKey, _migrationFailed);
        await CrashReportingService.logEvent('migration_failed');
        return false;
      }
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Migration check/execution failed',
      );
      
      // Mark migration as failed
      try {
        await DatabaseService.setMetadata(_migrationKey, _migrationFailed);
      } catch (_) {
        // Ignore errors when setting failure status
      }
      
      return false;
    }
  }

  /// Migrate data from SharedPreferences to SQLite
  static Future<bool> _migrateFromSharedPreferences() async {
    try {
      // Load existing mood entries from SharedPreferences
      final existingEntries = await MoodStorage.loadMoodEntries();
      
      if (existingEntries.isEmpty) {
        // No data to migrate
        return true;
      }

      // Check if SQLite already has data
      final sqliteEntries = await DatabaseService.getAllMoodEntries();
      if (sqliteEntries.isNotEmpty) {
        // SQLite already has data, decide on merge strategy
        return await _mergeExistingData(existingEntries, sqliteEntries);
      }

      // Migrate all entries to SQLite
      for (final entry in existingEntries) {
        await DatabaseService.insertMoodEntry(entry);
      }

      // Log successful migration
      await CrashReportingService.logEvent('data_migrated', parameters: {
        'entries_count': existingEntries.length,
        'source': 'shared_preferences',
        'destination': 'sqlite',
      });

      // Optionally clear SharedPreferences data after successful migration
      // Uncomment the next line if you want to remove old data
      // await MoodStorage.clearAllData();

      return true;
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'SharedPreferences to SQLite migration failed',
      );
      return false;
    }
  }

  /// Merge existing data from SharedPreferences and SQLite
  static Future<bool> _mergeExistingData(
    List<MoodEntry> sharedPrefsEntries,
    List<MoodEntry> sqliteEntries,
  ) async {
    try {
      // Create a map of existing SQLite entries by ID for quick lookup
      final existingIds = sqliteEntries.map((e) => e.id).toSet();
      
      // Add only new entries from SharedPreferences
      int newEntriesCount = 0;
      for (final entry in sharedPrefsEntries) {
        if (!existingIds.contains(entry.id)) {
          await DatabaseService.insertMoodEntry(entry);
          newEntriesCount++;
        }
      }

      // Log merge results
      await CrashReportingService.logEvent('data_merged', parameters: {
        'shared_prefs_entries': sharedPrefsEntries.length,
        'sqlite_entries': sqliteEntries.length,
        'new_entries_added': newEntriesCount,
      });

      return true;
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Data merge during migration failed',
      );
      return false;
    }
  }

  /// Get migration status
  static Future<String> getMigrationStatus() async {
    try {
      final status = await DatabaseService.getMetadata(_migrationKey);
      return status ?? _migrationPending;
    } catch (e) {
      return _migrationFailed;
    }
  }

  /// Force retry migration
  static Future<bool> retryMigration() async {
    try {
      // Reset migration status
      await DatabaseService.setMetadata(_migrationKey, _migrationPending);
      
      // Perform migration
      return await performMigrationIfNeeded();
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Migration retry failed',
      );
      return false;
    }
  }

  /// Validate migration integrity
  static Future<bool> validateMigration() async {
    try {
      // Load data from both sources
      final sharedPrefsEntries = await MoodStorage.loadMoodEntries();
      final sqliteEntries = await DatabaseService.getAllMoodEntries();

      // If SharedPreferences is empty, migration is valid
      if (sharedPrefsEntries.isEmpty) {
        return true;
      }

      // Check if all SharedPreferences entries exist in SQLite
      final sqliteIds = sqliteEntries.map((e) => e.id).toSet();
      final missingEntries = sharedPrefsEntries
          .where((entry) => !sqliteIds.contains(entry.id))
          .toList();

      if (missingEntries.isNotEmpty) {
        // Some entries are missing, log this
        await CrashReportingService.logEvent('migration_validation_failed', parameters: {
          'missing_entries_count': missingEntries.length,
          'total_shared_prefs_entries': sharedPrefsEntries.length,
          'total_sqlite_entries': sqliteEntries.length,
        });
        return false;
      }

      // Migration is valid
      await CrashReportingService.logEvent('migration_validation_success');
      return true;
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Migration validation failed',
      );
      return false;
    }
  }

  /// Get migration statistics
  static Future<Map<String, dynamic>> getMigrationStats() async {
    try {
      final sharedPrefsEntries = await MoodStorage.loadMoodEntries();
      final sqliteEntries = await DatabaseService.getAllMoodEntries();
      final migrationStatus = await getMigrationStatus();
      final dbStats = await DatabaseService.getDatabaseStats();

      return {
        'migration_status': migrationStatus,
        'shared_prefs_entries': sharedPrefsEntries.length,
        'sqlite_entries': sqliteEntries.length,
        'database_stats': dbStats,
        'migration_completed': migrationStatus == _migrationCompleted,
        'validation_passed': await validateMigration(),
      };
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to get migration statistics',
      );
      return {
        'migration_status': 'error',
        'error': e.toString(),
      };
    }
  }

  /// Clean up old SharedPreferences data after successful migration
  static Future<void> cleanupOldData() async {
    try {
      final migrationStatus = await getMigrationStatus();
      
      if (migrationStatus == _migrationCompleted) {
        final validationPassed = await validateMigration();
        
        if (validationPassed) {
          // Clear SharedPreferences data
          await MoodStorage.clearAllData();
          
          await CrashReportingService.logEvent('old_data_cleaned_up');
        }
      }
    } catch (e, stackTrace) {
      await CrashReportingService.reportError(
        e,
        stackTrace,
        context: 'Failed to cleanup old data',
      );
    }
  }
}