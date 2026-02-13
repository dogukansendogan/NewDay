import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_day/features/goals/domain/goal_model.dart'; // Tam yol

class GoalNotifier extends Notifier<List<Goal>> {
  @override
  List<Goal> build() {
    // Başlangıç için 2 örnek hedef
    return [
      Goal(title: "Kitap Okuma", category: "Gelişim", totalSteps: 50, currentSteps: 12, color: Colors.purple),
      Goal(title: "Para Biriktirme", category: "Finans", totalSteps: 100, currentSteps: 45, color: Colors.green),
    ];
  }

  // Yeni Hedef Ekle
  void addGoal(String title, int totalSteps, Color color) {
    final newGoal = Goal(
      title: title,
      category: "Genel",
      totalSteps: totalSteps,
      color: color,
    );
    state = [...state, newGoal];
  }

  // İlerlemeyi Artır (+1)
  void incrementProgress(String id) {
    state = [
      for (final goal in state)
        if (goal.id == id && goal.currentSteps < goal.totalSteps)
          goal.copyWith(currentSteps: goal.currentSteps + 1)
        else
          goal
    ];
  }
  
  // Hedefi Sil
  void deleteGoal(String id) {
    state = state.where((g) => g.id != id).toList();
  }
}

final goalProvider = NotifierProvider<GoalNotifier, List<Goal>>(() {
  return GoalNotifier();
});