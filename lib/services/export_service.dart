import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import '../models/mood_entry.dart';

class ExportService {
  static Future<String> exportToCSV(List<MoodEntry> entries) async {
    // Create CSV data
    List<List<dynamic>> csvData = [
      ['Date', 'Time', 'Mood', 'Emoji', 'Note'], // Header
    ];

    for (final entry in entries) {
      csvData.add([
        '${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year}',
        '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
        entry.mood,
        entry.emoji,
        entry.note.isEmpty ? 'No note' : entry.note,
      ]);
    }

    // Convert to CSV string
    String csvString = const ListToCsvConverter().convert(csvData);

    // Get the app's document directory
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/mood_data_$timestamp.csv');

    // Write to file
    await file.writeAsString(csvString);

    return file.path;
  }

  static Future<Map<String, dynamic>> exportSummaryReport(List<MoodEntry> entries) async {
    if (entries.isEmpty) {
      return {
        'success': false,
        'message': 'No data to export',
      };
    }

    // Calculate statistics
    final moodFrequency = <String, int>{};
    for (final entry in entries) {
      moodFrequency[entry.mood] = (moodFrequency[entry.mood] ?? 0) + 1;
    }

    final mostCommonMood = moodFrequency.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    final oldestEntry = entries.reduce((a, b) => 
        a.timestamp.isBefore(b.timestamp) ? a : b);
    
    final newestEntry = entries.reduce((a, b) => 
        a.timestamp.isAfter(b.timestamp) ? a : b);

    // Create summary text
    final summary = '''
MOOD TRACKER SUMMARY REPORT
Generated on: ${DateTime.now().toString().split('.')[0]}

OVERVIEW:
- Total entries: ${entries.length}
- Date range: ${_formatDate(oldestEntry.timestamp)} to ${_formatDate(newestEntry.timestamp)}
- Most common mood: ${mostCommonMood.key} (${mostCommonMood.value} times)

MOOD DISTRIBUTION:
${moodFrequency.entries.map((e) => '- ${e.key}: ${e.value} times (${((e.value / entries.length) * 100).toStringAsFixed(1)}%)').join('\n')}

RECENT ENTRIES (Last 5):
${entries.take(5).map((e) => '- ${_formatDate(e.timestamp)}: ${e.emoji} ${e.mood}${e.note.isNotEmpty ? ' - "${e.note}"' : ''}').join('\n')}

---
Exported from Mood Notes App
''';

    // Save summary to file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/mood_summary_$timestamp.txt');
    await file.writeAsString(summary);

    return {
      'success': true,
      'filePath': file.path,
      'summary': summary,
    };
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static Future<void> shareData(List<MoodEntry> entries, BuildContext context) async {
    try {
      final csvPath = await exportToCSV(entries);
      final summaryResult = await exportSummaryReport(entries);

      if (summaryResult['success']) {
        // Show success dialog
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.file_download, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Export Successful'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your mood data has been exported successfully!'),
                  const SizedBox(height: 16),
                  Text('CSV file: ${csvPath.split('/').last}'),
                  Text('Summary: ${summaryResult['filePath'].split('/').last}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Files saved to Documents folder.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
