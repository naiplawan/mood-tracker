import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../constants/mood_data.dart';
import '../utils/date_utils.dart' as date_utils;

class MoodCard extends StatelessWidget {
  final MoodEntry entry;
  final VoidCallback onDelete;

  const MoodCard({
    super.key,
    required this.entry,
    required this.onDelete,
  });  @override
  Widget build(BuildContext context) {
    final moodColor = MoodData.getMoodColor(entry.mood);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Optional: Add tap functionality to view details
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildMoodIcon(moodColor),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.mood,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: moodColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date_utils.DateUtils.formatDate(entry.timestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.outlined(
                    onPressed: () {
                      // Show delete dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 24,
                          ),
                          title: Text(
                            'Delete mood entry',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          content: Text(
                            'Are you sure you want to delete this mood entry?',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onDelete();
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.error,
                                foregroundColor: Theme.of(context).colorScheme.onError,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    tooltip: 'More options',
                    style: IconButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
              if (entry.note.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: moodColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: moodColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    entry.note,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }  Widget _buildMoodIcon(Color moodColor) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: moodColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: moodColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          entry.emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
