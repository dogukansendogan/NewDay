import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final bool isDone;
  final String category;
  
  // YENİ: Saat aralığı (Örn: "14:00" - "16:30")
  final String? startTime;
  final String? endTime;

  Task({
    String? id,
    required this.title,
    this.description = '',
    required this.date,
    this.isDone = false,
    this.category = 'Genel',
    this.startTime,
    this.endTime,
  }) : id = id ?? const Uuid().v4();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    bool? isDone,
    String? category,
    String? startTime,
    String? endTime,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isDone: isDone ?? this.isDone,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}