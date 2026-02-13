import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FitnessState {
  final Duration duration;
  final int calories;
  final int heartRate;
  final bool isRunning;
  final String activity;
  final List<double> graphData; // Grafik için son 30 veri noktası

  FitnessState({
    required this.duration,
    required this.calories,
    required this.heartRate,
    required this.isRunning,
    required this.activity,
    required this.graphData,
  });

  FitnessState copyWith({
    Duration? duration,
    int? calories,
    int? heartRate,
    bool? isRunning,
    String? activity,
    List<double>? graphData,
  }) {
    return FitnessState(
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      heartRate: heartRate ?? this.heartRate,
      isRunning: isRunning ?? this.isRunning,
      activity: activity ?? this.activity,
      graphData: graphData ?? this.graphData,
    );
  }
}

class FitnessNotifier extends Notifier<FitnessState> {
  Timer? _timer;
  final Random _rnd = Random();

  @override
  FitnessState build() {
    // Başlangıçta boş bir grafik listesi oluştur
    return FitnessState(
      duration: Duration.zero,
      calories: 0,
      heartRate: 70,
      isRunning: false,
      activity: 'CYBER RUN',
      graphData: List.generate(40, (index) => 0.2), // Düz çizgi
    );
  }

  void setActivity(String newActivity) {
    HapticFeedback.selectionClick();
    state = state.copyWith(activity: newActivity);
  }

  void toggleWorkout() {
    if (state.isRunning) {
      _pause();
    } else {
      _start();
    }
  }

  void _start() {
    HapticFeedback.heavyImpact();
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      // Her yarım saniyede bir güncelleme (Daha akıcı grafik için)
      
      // 1. Süre (Sadece tam saniyelerde artır)
      final addSecond = timer.tick % 2 == 0;
      final newDuration = addSecond ? state.duration + const Duration(seconds: 1) : state.duration;
      
      // 2. Yeni Grafik Verisi Üret (Rastgele dalgalanma)
      double signal = 0.3 + _rnd.nextDouble() * 0.5; // 0.3 ile 0.8 arası
      if (_rnd.nextDouble() > 0.8) signal = 1.0; // Arada bir zirve yap (Nabız atışı)
      
      // Listeyi kaydır: İlki sil, sona yenisini ekle
      List<double> newGraph = List.from(state.graphData);
      newGraph.removeAt(0);
      newGraph.add(signal);

      // 3. Kalori ve Nabız
      int newCal = state.calories + (addSecond ? 1 : 0);
      int newHR = 80 + (signal * 60).toInt(); // Grafiğe bağlı nabız

      state = state.copyWith(
        duration: newDuration,
        calories: newCal,
        heartRate: newHR,
        graphData: newGraph,
      );
    });
  }

  void _pause() {
    HapticFeedback.mediumImpact();
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    HapticFeedback.mediumImpact();
    _timer?.cancel();
    state = build(); // Sıfırla
  }
}

final fitnessProvider = NotifierProvider<FitnessNotifier, FitnessState>(() => FitnessNotifier());