/// Mood enum used in daily check-ins.
enum Mood {
  great,
  good,
  okay,
  tired,
  exhausted;

  String get label => switch (this) {
        Mood.great => 'Great',
        Mood.good => 'Good',
        Mood.okay => 'Okay',
        Mood.tired => 'Tired',
        Mood.exhausted => 'Exhausted',
      };

  String get emoji => switch (this) {
        Mood.great => '😄',
        Mood.good => '🙂',
        Mood.okay => '😐',
        Mood.tired => '😩',
        Mood.exhausted => '😴',
      };

  static Mood fromString(String v) => switch (v.toLowerCase()) {
        'good' => Mood.good,
        'okay' => Mood.okay,
        'tired' => Mood.tired,
        'exhausted' => Mood.exhausted,
        _ => Mood.great,
      };
}

/// Daily check-in entity.
class CheckinEntity {
  final String id;
  final String userId;
  final DateTime date;
  final Mood mood;
  final int? energyLevel;   // 1–5
  final int? sorenessLevel; // 1–5
  final int? stressLevel;   // 1–5

  const CheckinEntity({
    required this.id,
    required this.userId,
    required this.date,
    required this.mood,
    this.energyLevel,
    this.sorenessLevel,
    this.stressLevel,
  });
}
