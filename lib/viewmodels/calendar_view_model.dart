import 'package:table_calendar/table_calendar.dart';
import '../models/mood_entry.dart';
import 'base_view_model.dart';

/// ViewModel for the Calendar page
class CalendarViewModel extends BaseViewModel {
  List<MoodEntry> _moodEntries = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<MoodEntry> _selectedEvents = [];

  // Getters
  List<MoodEntry> get moodEntries => _moodEntries;
  CalendarFormat get calendarFormat => _calendarFormat;
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  List<MoodEntry> get selectedEvents => _selectedEvents;

  /// Initialize the calendar view model
  void initialize(List<MoodEntry> moodEntries) {
    _moodEntries = moodEntries;
    _selectedDay = DateTime.now();
    _updateSelectedEvents();
    notifyListeners();
  }

  /// Update mood entries
  void updateMoodEntries(List<MoodEntry> moodEntries) {
    _moodEntries = moodEntries;
    _updateSelectedEvents();
    notifyListeners();
  }

  /// Get events for a specific day
  List<MoodEntry> getEventsForDay(DateTime day) {
    return _moodEntries.where((entry) => isSameDay(entry.timestamp, day)).toList();
  }

  /// Handle day selection
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _selectedDay = selectedDay;
    _focusedDay = focusedDay;
    _updateSelectedEvents();
    notifyListeners();
  }

  /// Handle format change
  void onFormatChanged(CalendarFormat format) {
    _calendarFormat = format;
    notifyListeners();
  }

  /// Handle page change
  void onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    notifyListeners();
  }

  /// Update selected events based on selected day
  void _updateSelectedEvents() {
    if (_selectedDay != null) {
      _selectedEvents = getEventsForDay(_selectedDay!);
    } else {
      _selectedEvents = [];
    }
  }

  /// Check if a day has events
  bool hasEventsForDay(DateTime day) {
    return getEventsForDay(day).isNotEmpty;
  }

  /// Get the primary mood for a day (most recent entry)
  String? getPrimaryMoodForDay(DateTime day) {
    final events = getEventsForDay(day);
    if (events.isNotEmpty) {
      events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return events.first.mood;
    }
    return null;
  }
}
