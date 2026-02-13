import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Goal {
  final String id;
  final String title;
  final String category; // Spor, Para, Kariyer
  final int currentSteps; // Şu an kaçıncı adımdayız?
  final int totalSteps;   // Hedef kaç adım?
  final Color color;

  Goal({
    String? id,
    required this.title,
    required this.category,
    this.currentSteps = 0,
    required this.totalSteps,
    required this.color,
  }) : id = id ?? const Uuid().v4();

  // İlerlemeyi güncellemek için kopya oluşturucu
  Goal copyWith({
    String? id,
    String? title,
    String? category,
    int? currentSteps,
    int? totalSteps,
    Color? color,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      currentSteps: currentSteps ?? this.currentSteps,
      totalSteps: totalSteps ?? this.totalSteps,
      color: color ?? this.color,
    );
  }
}