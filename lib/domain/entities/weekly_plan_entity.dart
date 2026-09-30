import 'dart:convert';

class DailyPlanItem {
  final int day;
  final String title;
  final String description;
  final int durationMinutes;
  final bool isRestDay;
  final bool isCompleted;

  DailyPlanItem({
    required this.day,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.isRestDay,
    this.isCompleted = false,
  });

  DailyPlanItem copyWith({
    int? day,
    String? title,
    String? description,
    int? durationMinutes,
    bool? isRestDay,
    bool? isCompleted,
  }) {
    return DailyPlanItem(
      day: day ?? this.day,
      title: title ?? this.title,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isRestDay: isRestDay ?? this.isRestDay,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'title': title,
      'description': description,
      'durationMinutes': durationMinutes,
      'isRestDay': isRestDay,
      'isCompleted': isCompleted,
    };
  }

  factory DailyPlanItem.fromMap(Map<String, dynamic> map) {
    return DailyPlanItem(
      day: map['day']?.toInt() ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      durationMinutes: map['durationMinutes']?.toInt() ?? 0,
      isRestDay: map['isRestDay'] ?? false,
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class WeeklyPlanEntity {
  final String id;
  final String userId;
  final List<DailyPlanItem> days;
  final DateTime createdAt;

  WeeklyPlanEntity({
    required this.id,
    required this.userId,
    required this.days,
    required this.createdAt,
  });

  WeeklyPlanEntity copyWith({
    String? id,
    String? userId,
    List<DailyPlanItem>? days,
    DateTime? createdAt,
  }) {
    return WeeklyPlanEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      days: days ?? this.days,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'days': days.map((x) => x.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory WeeklyPlanEntity.fromMap(Map<String, dynamic> map) {
    return WeeklyPlanEntity(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      days: List<DailyPlanItem>.from(map['days']?.map((x) => DailyPlanItem.fromMap(x)) ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  String toJson() => json.encode(toMap());

  factory WeeklyPlanEntity.fromJson(String source) => WeeklyPlanEntity.fromMap(json.decode(source));
}
