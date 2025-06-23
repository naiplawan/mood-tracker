import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:ui';
import '../models/mood_entry.dart';
import '../constants/mood_data.dart';
import '../utils/animations.dart';

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

  Color _colorWithOpacity(Color color, double opacity) {
    return color.withValues(
      red: color.red / 255,
      green: color.green / 255,
      blue: color.blue / 255,
      alpha: opacity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A),
            const Color(0xFF1E293B),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Calendar',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            SlideTransitionAnimation(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _colorWithOpacity(Colors.white, 0.1),
                        _colorWithOpacity(Colors.white, 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _colorWithOpacity(Colors.white, 0.1),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: TableCalendar<MoodEntry>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        eventLoader: _getEventsForDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          _selectedEvents.value = _getEventsForDay(selectedDay);
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          defaultTextStyle: const TextStyle(color: Colors.white70),
                          weekendTextStyle: const TextStyle(color: Colors.white70),
                          holidayTextStyle: const TextStyle(color: Colors.white70),
                          selectedDecoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                _colorWithOpacity(Theme.of(context).primaryColor, 0.8),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: _colorWithOpacity(Colors.white, 0.1),
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                _colorWithOpacity(Theme.of(context).primaryColor, 0.8),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: _colorWithOpacity(Colors.white, 0.8),
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: _colorWithOpacity(Colors.white, 0.8),
                          ),
                          titleTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(color: Colors.white70),
                          weekendStyle: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<List<MoodEntry>>(
                valueListenable: _selectedEvents,
                builder: (context, events, _) {
                  return SlideTransitionAnimation(
                    startOffset: const Offset(0, 0.2),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        final moodColor = MoodData.getMoodColor(event.mood);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _colorWithOpacity(Colors.white, 0.1),
                                _colorWithOpacity(Colors.white, 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _colorWithOpacity(moodColor, 0.3),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _colorWithOpacity(moodColor, 0.8),
                                        _colorWithOpacity(moodColor, 0.6),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    MoodData.getMoodEmoji(event.mood),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                title: Text(
                                  event.mood,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: event.note.isNotEmpty
                                    ? Text(
                                        event.note,
                                        style: TextStyle(
                                          color: _colorWithOpacity(Colors.white, 0.7),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
