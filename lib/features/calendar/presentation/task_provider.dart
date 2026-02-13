import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_day/features/calendar/domain/task_model.dart';

class TaskNotifier extends Notifier<List<Task>> {
  
  @override
  List<Task> build() {
    return [
      Task(
        title: "NewDay Başlangıç", 
        description: "Uygulamayı test et", 
        date: DateTime.now(), 
        category: "Kariyer",
        startTime: "09:00",
        endTime: "10:00"
      ),
    ];
  }

  void addTask({
    required String title, 
    required String description, 
    required String category, 
    required DateTime taskDate,
    String? startTime,
    String? endTime,
  }) {
    final newTask = Task(
      title: title,
      description: description,
      date: taskDate,
      category: category,
      startTime: startTime,
      endTime: endTime,
    );
    state = [...state, newTask];
  }

  // YENİ EKLENEN FONKSİYON: GÜNCELLEME
  void updateTask({
    required String id,
    required String title,
    required String description,
    required String category,
    String? startTime,
    String? endTime,
  }) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(
            title: title,
            description: description,
            category: category,
            startTime: startTime,
            endTime: endTime,
          )
        else
          task,
    ];
  }

  void toggleTask(String id) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(isDone: !task.isDone)
        else
          task,
    ];
  }

  void deleteTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }
}

final taskProvider = NotifierProvider<TaskNotifier, List<Task>>(() {
  return TaskNotifier();
});