import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';

import '../../../../core/theme/app_colors.dart';
import '../domain/goal_model.dart';
import 'goal_provider.dart';
import 'trophy_screen.dart'; // YENİ: Sayfayı import ettik

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _bgController;

  final TextEditingController _titleController = TextEditingController();
  final List<Color> _goalColors = [
    const Color(0xFFFF3D00), 
    const Color(0xFF2962FF), 
    const Color(0xFF00C853), 
    const Color(0xFFFFD600), 
    const Color(0xFFAA00FF), 
    const Color(0xFFC51162), 
  ];
  
  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _bgController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _checkCompletionAndCelebrate(Goal goal) {
    if (goal.currentSteps + 1 >= goal.totalSteps) {
      _confettiController.play();
    }
  }

  // YENİ: Tamamlananları filtreleyip sayfayı açan fonksiyon
  void _openTrophyRoom(List<Goal> allGoals) {
    final completedGoals = allGoals.where((g) => g.currentSteps >= g.totalSteps).toList();
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TrophyScreen(completedGoals: completedGoals)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalProvider);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))
              ]
            ),
            child: FloatingActionButton.extended(
              onPressed: () => _showCreateGoalModal(context),
              backgroundColor: const Color(0xFF212121),
              elevation: 0,
              icon: const Icon(Icons.flag_rounded, color: Colors.white),
              label: Text("HEDEF BELİRLE", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ).animate().scale(delay: 500.ms, curve: Curves.elasticOut),
          
          body: Stack(
            children: [
              _buildChallengerBackground(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header'a goals listesini gönderiyoruz ki içindeki butona tıklayınca filtreleme yapabilsin
                      _buildHeader(goals),
                      const SizedBox(height: 30),
                      Expanded(child: _buildGoalsList(goals)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            maxBlastForce: 10,
            minBlastForce: 5,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.2,
            colors: const [Colors.red, Colors.blue, Colors.yellow, Colors.purple], 
          ),
        ),
      ],
    );
  }

  Widget _buildChallengerBackground() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: const Color(0xFFF5F5F7)),
            Positioned(
              top: -50 + (_bgController.value * 30),
              right: -100 + (_bgController.value * 20),
              child: Container(
                width: 400, height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [const Color(0xFFFF5252).withOpacity(0.15), Colors.transparent]),
                ),
              ),
            ),
            Positioned(
              bottom: 100 - (_bgController.value * 50),
              left: -100,
              child: Container(
                width: 500, height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [const Color(0xFF7C4DFF).withOpacity(0.15), Colors.transparent]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // HEADER GÜNCELLENDİ
  Widget _buildHeader(List<Goal> allGoals) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 32),
                const SizedBox(width: 10),
                Text(
                  "ARENA",
                  style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF212121), letterSpacing: 2),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Sınırlarını zorla.",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),

        // YENİ: KUPA ODASI BUTONU
        GestureDetector(
          onTap: () => _openTrophyRoom(allGoals),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.military_tech_rounded, color: Color(0xFF212121), size: 28),
          ),
        ).animate().scale(delay: 800.ms, curve: Curves.elasticOut),
      ],
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }

  Widget _buildGoalsList(List<Goal> goals) {
    // Sadece tamamlanmamış hedefleri ana listede gösterelim mi? 
    // Hayır, hepsini gösterelim, tamamlananlar zaten "kupa" ikonlu oluyor.
    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
              child: Icon(Icons.flag, size: 60, color: Colors.grey.shade400),
            ).animate().scale(duration: 1.seconds, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text("Henüz bir meydan okuma yok.", style: GoogleFonts.poppins(color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            Text("Başlamak için butona bas!", style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        return _buildChallengerCard(goals[index], index);
      },
    );
  }

  Widget _buildChallengerCard(Goal goal, int index) {
    final double progress = goal.currentSteps / goal.totalSteps;
    final bool isCompleted = progress >= 1.0;

    return Dismissible(
      key: Key(goal.id),
      onDismissed: (_) { ref.read(goalProvider.notifier).deleteGoal(goal.id); },
      background: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(color: const Color(0xFFD32F2F), borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_forever, color: Colors.white, size: 32),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
            BoxShadow(color: goal.color.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: goal.color,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: goal.color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(goal.category.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: goal.color)),
                          ),
                          const SizedBox(height: 8),
                          Text(goal.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF212121))),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text("${goal.currentSteps}", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: goal.color)),
                              Text(" / ${goal.totalSteps}", style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 90, height: 90,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey.shade100,
                            color: goal.color,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        if (!isCompleted)
                          Material(
                            color: goal.color,
                            shape: const CircleBorder(),
                            elevation: 4,
                            child: InkWell(
                              onTap: () {
                                _checkCompletionAndCelebrate(goal);
                                ref.read(goalProvider.notifier).incrementProgress(goal.id);
                              },
                              customBorder: const CircleBorder(),
                              child: const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Icon(Icons.add, color: Colors.white, size: 24),
                              ),
                            ),
                          )
                        else
                          Icon(Icons.emoji_events, color: goal.color, size: 36).animate().scale(curve: Curves.elasticOut),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideX(begin: 0.2, end: 0, delay: (100 * index).ms);
  }

  void _showCreateGoalModal(BuildContext context) {
    _titleController.clear();
    Color selectedColor = _goalColors[0];
    double selectedSteps = 10;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("YENİ HEDEF", style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF212121), letterSpacing: 1)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "Örn: 50 Kitap Oku",
                      filled: true, fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      prefixIcon: Icon(Icons.flag, color: selectedColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("TEMA RENGİ", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _goalColors.map((color) {
                      final isSelected = selectedColor == color;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedColor = color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isSelected ? 40 : 32,
                          height: isSelected ? 40 : 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("HEDEF SAYISI", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text("${selectedSteps.toInt()}", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w900, color: selectedColor)),
                    ],
                  ),
                  Slider(
                    value: selectedSteps,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    activeColor: selectedColor,
                    inactiveColor: selectedColor.withOpacity(0.2),
                    onChanged: (val) => setModalState(() => selectedSteps = val),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF212121),
                        foregroundColor: Colors.white,
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        if (_titleController.text.isNotEmpty) {
                          ref.read(goalProvider.notifier).addGoal(
                             _titleController.text,
                             selectedSteps.toInt(),
                             selectedColor
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: Text("HEDEFİ BAŞLAT 🚀", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}