class MoodEntry {
  final String id;
  final String mood;
  final String emoji;
  final String note;
  final DateTime timestamp;

  MoodEntry({
    required this.id,
    required this.mood,
    required this.emoji,
    required this.note,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood': mood,
      'emoji': emoji,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'],
      mood: json['mood'],
      emoji: json['emoji'],
      note: json['note'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
