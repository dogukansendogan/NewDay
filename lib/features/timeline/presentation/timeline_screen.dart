import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:new_day/core/theme/app_colors.dart';
// KOMŞU İMPORT
import 'timeline_provider.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final memories = ref.watch(timelineProvider);
    final notifier = ref.read(timelineProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMemoryModal(context, notifier),
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ).animate().scale(delay: 500.ms, curve: Curves.elasticOut),
      
      body: Stack(
        children: [
          // ARKA PLAN EFEKTLERİ (Nebula)
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.15),
                boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 100, spreadRadius: 20)],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_stories, color: Colors.deepPurpleAccent, size: 30),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("CHRONICLES", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 20, letterSpacing: 3)),
                          Text("Hayatının Hikayesi", style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),

                // TIMELINE LİSTESİ
                Expanded(
                  child: memories.isEmpty
                      ? Center(child: Text("Henüz bir anı yok.", style: GoogleFonts.poppins(color: Colors.white30)))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: memories.length,
                          itemBuilder: (context, index) {
                            final memory = memories[index];
                            // Son eleman mı kontrolü (Çizgiyi kesmek için)
                            final isLast = index == memories.length - 1;
                            return _buildTimelineItem(memory, isLast, index, notifier);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Memory memory, bool isLast, int index, TimelineNotifier notifier) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SOL TARAFTAKİ ZAMAN ÇİZGİSİ
          Column(
            children: [
              // Düğüm (Node)
              Container(
                width: 16, height: 16,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.deepPurpleAccent, width: 3),
                  boxShadow: [BoxShadow(color: Colors.deepPurpleAccent.withOpacity(0.5), blurRadius: 10)]
                ),
              ),
              // Çizgi (Line)
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.deepPurpleAccent, Colors.deepPurpleAccent.withOpacity(0.1)]
                      )
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 20),

          // SAĞ TARAFTAKİ KART
          Expanded(
            child: Dismissible(
              key: Key(memory.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => notifier.deleteMemory(memory.id),
              background: Container(alignment: Alignment.centerRight, child: const Icon(Icons.delete, color: Colors.red)),
              child: Container(
                margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resim Varsa Göster
                    if (memory.image != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.file(
                          memory.image!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.deepPurpleAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                child: Text(DateFormat("dd MMM yyyy").format(memory.date), style: GoogleFonts.spaceMono(color: Colors.deepPurpleAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              Text(memory.moodEmoji, style: const TextStyle(fontSize: 20)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(memory.title, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(memory.description, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 150).ms).slideX(begin: 0.2, end: 0);
  }

  void _showAddMemoryModal(BuildContext context, TimelineNotifier notifier) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedEmoji = "🚀";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
              left: 20, right: 20, top: 20
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A).withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ANIYI ÖLÜMSÜZLEŞTİR", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 20),
                
                TextField(
                  controller: titleCtrl,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Başlık", hintStyle: TextStyle(color: Colors.white38),
                    filled: true, fillColor: Colors.white10,
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Neler oldu?", hintStyle: TextStyle(color: Colors.white38),
                    filled: true, fillColor: Colors.white10,
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Emoji Seçici (Basit)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ["🚀", "🔥", "❤️", "🎉", "💡", "💪"].map((e) {
                    return GestureDetector(
                      onTap: () => selectedEmoji = e, // Basit seçim, UI güncellemek için stateful gerekirdi ama hızlıca yapıyoruz
                      child: Text(e, style: const TextStyle(fontSize: 28)),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (titleCtrl.text.isNotEmpty) {
                        // Önce galeri açılacak, sonra kayıt yapılacak
                        notifier.addMemory(titleCtrl.text, descCtrl.text, selectedEmoji);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    label: Text("FOTOĞRAF SEÇ & KAYDET", style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}