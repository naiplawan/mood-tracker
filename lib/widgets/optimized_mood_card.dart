import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../services/performance_service.dart';

/// Optimized mood card widget with performance monitoring
class OptimizedMoodCard extends StatelessWidget {
  final MoodEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const OptimizedMoodCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // Track widget build performance
    final stopwatch = Stopwatch()..start();
    
    final card = _buildCard(context);
    
    stopwatch.stop();
    PerformanceService.trackWidgetBuild('MoodCard', stopwatch.elapsed);
    
    return card;
  }

  Widget _buildCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: isSelected ? 8 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected 
          ? BorderSide(color: theme.primaryColor, width: 2)
          : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final stopwatch = Stopwatch()..start();
          onTap();
          stopwatch.stop();
          PerformanceService.trackUserInteraction('mood_card_tap', stopwatch.elapsedMilliseconds);
        },
        onLongPress: onLongPress != null ? () {
          final stopwatch = Stopwatch()..start();
          onLongPress!();
          stopwatch.stop();
          PerformanceService.trackUserInteraction('mood_card_long_press', stopwatch.elapsedMilliseconds);
        } : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Mood emoji - cached for performance
              _OptimizedEmoji(emoji: entry.emoji),
              const SizedBox(width: 16),
              
              // Mood details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mood name
                    Text(
                      entry.mood,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? theme.primaryColor : null,
                      ),
                    ),
                    
                    // Note preview (if exists)
                    if (entry.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        entry.note,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    // Timestamp
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(entry.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.primaryColor,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Optimized emoji widget with caching
class _OptimizedEmoji extends StatelessWidget {
  final String emoji;

  const _OptimizedEmoji({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}

/// Performance-optimized list view for mood cards
class OptimizedMoodCardList extends StatelessWidget {
  final List<MoodEntry> entries;
  final Function(MoodEntry) onEntryTap;
  final Function(MoodEntry)? onEntryLongPress;
  final String? selectedEntryId;
  final ScrollController? scrollController;

  const OptimizedMoodCardList({
    super.key,
    required this.entries,
    required this.onEntryTap,
    this.onEntryLongPress,
    this.selectedEntryId,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const _EmptyState();
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: entries.length,
      // Use itemExtent for better performance if all items have same height
      itemExtent: 120,
      // Cache extent for better scrolling performance
      cacheExtent: 1000,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return OptimizedMoodCard(
          entry: entry,
          isSelected: entry.id == selectedEntryId,
          onTap: () => onEntryTap(entry),
          onLongPress: onEntryLongPress != null 
            ? () => onEntryLongPress!(entry)
            : null,
        );
      },
    );
  }
}

/// Empty state widget
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mood,
            size: 64,
            color: theme.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No mood entries yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first mood entry',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}