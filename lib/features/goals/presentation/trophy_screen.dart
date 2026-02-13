import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:new_day/core/theme/app_colors.dart';
import '../domain/goal_model.dart';

class TrophyScreen extends StatelessWidget {
  final List<Goal> completedGoals;

  const TrophyScreen({super.key, required this.completedGoals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Çok koyu mat siyah (Premium his)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text("ŞEREF SALONU", style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white)),
        centerTitle: true,
      ),
      body: completedGoals.isEmpty ? _buildEmptyState() : _buildTrophyGrid(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 20),
          Text("HENÜZ ZAFER YOK", style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white54)),
          const SizedBox(height: 10),
          Text("Arenaya dön ve savaşmaya başla.", style: GoogleFonts.poppins(color: Colors.white30)),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildTrophyGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Yan yana 2 madalya
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.8, // Dikey kartlar
      ),
      itemCount: completedGoals.length,
      itemBuilder: (context, index) {
        final goal = completedGoals[index];
        return _buildMedalCard(goal, index);
      },
    );
  }

  Widget _buildMedalCard(Goal goal, int index) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          // Kartın arkasına hedefin renginde hafif bir parlama (Glow)
          BoxShadow(color: goal.color.withOpacity(0.2), blurRadius: 20, spreadRadius: -5),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Madalya İkonu (Parlayan)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: goal.color.withOpacity(0.1),
              border: Border.all(color: goal.color.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(color: goal.color.withOpacity(0.4), blurRadius: 20, spreadRadius: 0)
              ]
            ),
            child: Icon(Icons.emoji_events_rounded, size: 40, color: goal.color),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(duration: 2.seconds, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)), // Hafif nefes alma efekti
          
          const SizedBox(height: 20),
          
          Text(
            "TAMAMLANDI",
            style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              goal.title.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "${goal.totalSteps} ADIM",
            style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: goal.color),
          ),
        ],
      ),
    ).animate().scale(delay: (100 * index).ms, curve: Curves.easeOutBack);
  }
}