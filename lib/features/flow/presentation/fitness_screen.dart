import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'fitness_provider.dart';

class FitnessScreen extends ConsumerWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // DEĞİŞKENLER BURADA TANIMLANIYOR
    final state = ref.watch(fitnessProvider); // fitnessState yerine state kullandık
    final notifier = ref.read(fitnessProvider.notifier);
    
    // Cyberpunk Renk Paleti
    final neonColor = state.isRunning ? const Color(0xFF00FFC2) : const Color(0xFF536DFE); 
    final bgColor = const Color(0xFF050505);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. ARKA PLAN IZGARASI (GRID)
          Positioned.fill(
            child: CustomPaint(painter: GridPainter()),
          ),
          
          // 2. ORTAM IŞIĞI (GLOW) - DÜZELTİLMİŞ ANİMASYON
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                color: neonColor.withOpacity(0.15), 
                boxShadow: [BoxShadow(color: neonColor.withOpacity(0.3), blurRadius: 100, spreadRadius: 20)]
              ),
            ),
          ).animate(
            target: state.isRunning ? 1 : 0,
            onPlay: (controller) => controller.repeat(reverse: true),
          ).scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.1, 1.1),
            duration: 2.seconds,
            curve: Curves.easeInOut,
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ÜST BAŞLIK & MOD SEÇİCİ ---
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("SYSTEM STATUS", style: GoogleFonts.spaceMono(fontSize: 10, color: Colors.grey, letterSpacing: 2)),
                          Text(state.isRunning ? "ONLINE" : "STANDBY", style: GoogleFonts.audiowide(fontSize: 20, color: state.isRunning ? const Color(0xFF00FFC2) : Colors.redAccent)),
                        ],
                      ),
                      const Icon(Icons.hub, color: Colors.white24),
                    ],
                  ),
                  
                  const SizedBox(height: 30),

                  // --- AKTİVİTE SEÇİCİ (YATAY) ---
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ["CYBER RUN", "WEIGHTS", "HIIT", "YOGA"].map((act) {
                        final isSelected = state.activity == act;
                        return GestureDetector(
                          onTap: () => notifier.setActivity(act),
                          child: AnimatedContainer(
                            duration: 200.ms,
                            margin: const EdgeInsets.only(right: 15),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? neonColor.withOpacity(0.2) : Colors.transparent,
                              border: Border.all(color: isSelected ? neonColor : Colors.white12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(act, style: GoogleFonts.spaceMono(color: isSelected ? Colors.white : Colors.white38, fontWeight: FontWeight.bold)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const Spacer(),

                  // --- ANA GÖSTERGE (KINETIC CORE) ---
                  Center(
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Dönen Dış Çemberler
                          Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white10, width: 1)),
                          ),
                          Container(
                            width: 280, height: 280,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: neonColor.withOpacity(0.3), width: 2)),
                          ).animate(target: state.isRunning ? 1 : 0, onPlay: (c) => c.repeat()).rotate(duration: 10.seconds),

                          // CANLI GRAFİK (ECG)
                          ClipOval(
                            child: Container(
                              width: 260, height: 260,
                              color: Colors.black,
                              child: CustomPaint(
                                painter: ChartPainter(data: state.graphData, color: neonColor),
                              ),
                            ),
                          ),

                          // Ortadaki Süre
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${state.duration.inMinutes.toString().padLeft(2, '0')}:${(state.duration.inSeconds % 60).toString().padLeft(2, '0')}",
                                style: GoogleFonts.spaceMono(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: neonColor, blurRadius: 15)]),
                              ),
                              Text("DURATION", style: GoogleFonts.spaceMono(fontSize: 10, color: Colors.white38, letterSpacing: 4)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // --- VERİ KARTLARI (ALT) ---
                  Row(
                    children: [
                      Expanded(child: _buildInfoCard("HEART RATE", "${state.heartRate}", "BPM", const Color(0xFFFF2E93))),
                      const SizedBox(width: 15),
                      Expanded(child: _buildInfoCard("ENERGY", "${state.calories}", "KCAL", const Color(0xFFFFD600))),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- KONTROL ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Reset Butonu
                      if (state.duration > Duration.zero)
                        IconButton(onPressed: notifier.reset, icon: const Icon(Icons.refresh, color: Colors.white30, size: 30)).animate().fadeIn(),
                      
                      const SizedBox(width: 20),

                      // BAŞLAT BUTONU (HEXAGON)
                      GestureDetector(
                        onTap: notifier.toggleWorkout,
                        child: AnimatedContainer(
                          duration: 300.ms,
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: neonColor,
                            borderRadius: BorderRadius.circular(20), 
                            boxShadow: [BoxShadow(color: neonColor.withOpacity(0.6), blurRadius: 20, spreadRadius: 2)],
                          ),
                          child: Icon(state.isRunning ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 40),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.spaceMono(fontSize: 10, color: Colors.white38)),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: GoogleFonts.audiowide(fontSize: 24, color: Colors.white)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(unit, style: GoogleFonts.spaceMono(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 2, width: 40, color: color.withOpacity(0.5)),
        ],
      ),
    );
  }
}

// --- ARKA PLAN IZGARA ÇİZİMİ ---
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.03)..strokeWidth = 1;
    const double step = 40;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- CANLI GRAFİK ÇİZİMİ ---
class ChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  ChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double widthStep = size.width / (data.length - 1);
    
    path.moveTo(0, size.height / 2); 

    for (int i = 0; i < data.length; i++) {
      double x = i * widthStep;
      double y = size.height - (data[i] * size.height * 0.6) - (size.height * 0.2);
      path.lineTo(x, y);
    }

    // Altına gölge
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
      
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color.withOpacity(0.3), Colors.transparent],
    );
    
    final fillPaint = Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) => true;
}