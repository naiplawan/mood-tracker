import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/mood_entry.dart';
import '../constants/mood_data.dart';

class CalendarPage extends StatefulWidget {
  final List<MoodEntry> moodEntries;

  const CalendarPage({super.key, required this.moodEntries});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<List<MoodEntry>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<MoodEntry> _getEventsForDay(DateTime day) {
    return widget.moodEntries.where((entry) => isSameDay(entry.timestamp, day)).toList();
  }

  Map<DateTime, List<MoodEntry>> _groupEventsByDay() {
    Map<DateTime, List<MoodEntry>> events = {};
    for (final entry in widget.moodEntries) {
      final date = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      if (events[date] != null) {
        events[date]!.add(entry);
      } else {
        events[date] = [entry];
      }
    }
    return events;
  }

  Color? _getDayColor(DateTime day) {
    final events = _getEventsForDay(day);
    if (events.isEmpty) return null;
    
    // Get the most recent mood for this day
    final latestMood = events.reduce((a, b) => 
      a.timestamp.isAfter(b.timestamp) ? a : b);
    
    return MoodData.getMoodColor(latestMood.mood).withOpacity(0.7);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Calendar'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
                _selectedEvents.value = _getEventsForDay(_selectedDay!);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8),
            child: TableCalendar<MoodEntry>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              
              // Calendar styling
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                holidayTextStyle: TextStyle(color: Theme.of(context).colorScheme.error),
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                canMarkersOverflow: false,
              ),
              
              // Header styling
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                formatButtonTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              
              // Day builder for custom styling
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final color = _getDayColor(day);
                  final events = _getEventsForDay(day);
                  
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: events.isNotEmpty ? Border.all(
                        color: color ?? Colors.transparent,
                        width: 2,
                      ) : null,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              color: color != null ? Colors.white : null,
                              fontWeight: events.isNotEmpty ? FontWeight.bold : null,
                            ),
                          ),
                          if (events.isNotEmpty)
                            Text(
                              MoodData.getMoodEmoji(events.last.mood),
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  final color = _getDayColor(day);
                  final events = _getEventsForDay(day);
                  
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color ?? Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (events.isNotEmpty)
                            Text(
                              MoodData.getMoodEmoji(events.last.mood),
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  final color = _getDayColor(day);
                  final events = _getEventsForDay(day);
                  
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color ?? Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              color: color != null ? Colors.white : Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (events.isNotEmpty)
                            Text(
                              MoodData.getMoodEmoji(events.last.mood),
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedEvents.value = _getEventsForDay(selectedDay);
                  });
                }
              },
              
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Legend
          _buildLegend(),
          
          const SizedBox(height: 8),
          
          // Selected day events
          Expanded(
            child: ValueListenableBuilder<List<MoodEntry>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return _buildEventsList(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Legend',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: MoodData.moods.take(5).map((mood) {
                final color = Color(int.parse(mood['color']!));
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      mood['name']!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(List<MoodEntry> events) {
    if (events.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedDay != null 
                    ? 'No moods logged on ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}'
                    : 'No moods logged on selected day',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _selectedDay != null 
                ? 'Moods on ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}'
                : 'Moods on selected day',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: events.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final event = events[index];
                final color = MoodData.getMoodColor(event.mood);
                
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        event.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  title: Text(
                    event.mood,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (event.note.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          event.note,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
