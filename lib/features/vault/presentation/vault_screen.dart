import 'dart:async';
import 'dart:ui';
import 'dart:math'; // DÜZELTME: 'as math' kısmını kaldırdık, artık direkt çalışır.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:new_day/features/vault/vault_provider.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> with TickerProviderStateMixin {
  late AnimationController _matrixController;
  late AnimationController _pulseController;
  late ScrollController _scrollController;
  
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isSearching = false;
  String _activeFilter = "ALL"; 
  bool _systemReady = false;

  @override
  void initState() {
    super.initState();
    _matrixController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scrollController = ScrollController();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _systemReady = true);
    });
  }

  @override
  void dispose() {
    _matrixController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vaultProvider);
    final notifier = ref.read(vaultProvider.notifier);

    final filteredNotes = state.notes.where((note) {
      final matchesSearch = note.title.toLowerCase().contains(_searchCtrl.text.toLowerCase()) || 
                            note.content.toLowerCase().contains(_searchCtrl.text.toLowerCase());
      final matchesTag = _activeFilter == "ALL" || note.tag.toUpperCase().contains(_activeFilter);
      return matchesSearch && matchesTag;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false, 
      
      floatingActionButton: _systemReady 
        ? FloatingActionButton(
            onPressed: () => _showCyberModal(context, notifier),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E676).withOpacity(0.2),
                border: Border.all(color: const Color(0xFF00E676), width: 2),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF00E676).withOpacity(0.4), blurRadius: 20, spreadRadius: 5)
                ]
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ).animate().scale(delay: 1.seconds, curve: Curves.elasticOut)
        : null,

      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _matrixController,
              builder: (context, child) {
                return CustomPaint(
                  painter: MatrixRainPainter(
                    animationValue: _matrixController.value,
                    color: state.isLocked ? Colors.redAccent : const Color(0xFF00FF41), 
                  ),
                );
              },
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ),

          if (_systemReady)
            SafeArea(
              child: Column(
                children: [
                  _buildCyberHeader(state.isLocked, notifier),
                  _buildFilterBar(),
                  AnimatedContainer(
                    duration: 300.ms,
                    height: _isSearching ? 60 : 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _isSearching 
                      ? _buildCyberSearch()
                      : const SizedBox(),
                  ),
                  Expanded(
                    child: filteredNotes.isEmpty 
                      ? _buildEmptyState()
                      : MasonryGridView.count(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          itemCount: filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = filteredNotes[index];
                            return HoloCard(
                              note: note, 
                              isLocked: state.isLocked, 
                              index: index, 
                              onDelete: () => notifier.deleteNote(note.id)
                            );
                          },
                        ),
                  ),
                ],
              ),
            )
          else
            _buildBootSequence(), 
        ],
      ),
    );
  }

  Widget _buildBootSequence() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.memory, size: 60, color: Colors.greenAccent)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1.seconds, color: Colors.white),
          const SizedBox(height: 20),
          // DÜZELTME: typewriter yerine fade+scale kullanıldı (Garanti çözüm)
          Text("INITIALIZING NEURAL LINK...", style: GoogleFonts.spaceMono(color: Colors.greenAccent, fontSize: 12))
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
        ],
      ),
    );
  }

  Widget _buildCyberHeader(bool isLocked, dynamic notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
        color: Colors.black.withOpacity(0.3),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlitchText(
                    text: "NEURAL VAULT",
                    style: GoogleFonts.orbitron(
                      fontSize: 22, 
                      fontWeight: FontWeight.w900, 
                      color: isLocked ? Colors.redAccent : Colors.white,
                      letterSpacing: 2
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: isLocked ? Colors.red : Colors.greenAccent, shape: BoxShape.circle)).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 500.ms),
                      const SizedBox(width: 6),
                      Text(
                        isLocked ? "ENCRYPTED MODE" : "SYSTEM ONLINE",
                        style: GoogleFonts.shareTechMono(
                          fontSize: 10, 
                          color: isLocked ? Colors.red : Colors.greenAccent
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white70),
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) _searchCtrl.clear();
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      notifier.toggleLock();
                    },
                    child: AnimatedContainer(
                      duration: 300.ms,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isLocked ? Colors.redAccent.withOpacity(0.2) : Colors.greenAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isLocked ? Colors.redAccent : Colors.greenAccent),
                      ),
                      child: Icon(
                        isLocked ? Icons.lock : Icons.lock_open_rounded,
                        color: isLocked ? Colors.redAccent : Colors.greenAccent,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ["ALL", "FIKIR", "KOD", "GIZLI", "FINANS"];
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isActive = _activeFilter == filter;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _activeFilter = filter);
            },
            child: AnimatedContainer(
              duration: 200.ms,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.transparent,
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive ? [BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 10)] : [],
              ),
              child: Center(
                child: Text(
                  filter,
                  style: GoogleFonts.spaceMono(
                    fontSize: 11, 
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.black : Colors.white54
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCyberSearch() {
    return TextField(
      controller: _searchCtrl,
      style: GoogleFonts.spaceMono(color: Colors.white),
      onChanged: (val) => setState(() {}),
      cursorColor: Colors.greenAccent,
      decoration: InputDecoration(
        hintText: "Search Database...",
        hintStyle: GoogleFonts.spaceMono(color: Colors.white24),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        prefixIcon: const Icon(Icons.code, color: Colors.greenAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.greenAccent)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sd_card_alert, size: 60, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 20),
          Text("NO DATA FRAGMENTS FOUND", style: GoogleFonts.orbitron(color: Colors.white24)),
        ],
      ),
    );
  }

  void _showCyberModal(BuildContext context, dynamic notifier) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
              left: 20, right: 20, top: 20
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A).withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("NEW DATA ENTRY", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Icon(Icons.wifi_protected_setup, color: Colors.greenAccent),
                  ],
                ),
                const Divider(color: Colors.white12, height: 30),
                
                Text("IDENTIFIER", style: GoogleFonts.spaceMono(color: Colors.greenAccent, fontSize: 10)),
                const SizedBox(height: 5),
                TextField(
                  controller: titleCtrl,
                  style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 18),
                  decoration: const InputDecoration(
                    hintText: "Enter Title...",
                    hintStyle: TextStyle(color: Colors.white12),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                  ),
                ),
                const SizedBox(height: 20),

                Text("DATA STREAM", style: GoogleFonts.spaceMono(color: Colors.greenAccent, fontSize: 10)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: TextField(
                    controller: contentCtrl,
                    maxLines: 5,
                    style: GoogleFonts.shareTechMono(color: Colors.white70),
                    decoration: const InputDecoration.collapsed(
                      hintText: "Input raw data here...",
                      hintStyle: TextStyle(color: Colors.white12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.isNotEmpty) {
                        Color tagColor = Colors.white;
                        if(titleCtrl.text.contains("Fikir")) tagColor = const Color(0xFF00E5FF);
                        else if(titleCtrl.text.contains("Kod")) tagColor = const Color(0xFF00E676);
                        else tagColor = const Color(0xFFFF2E93);

                        notifier.addNote(titleCtrl.text, contentCtrl.text, "#FIKIR", tagColor);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("UPLOAD TO VAULT", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
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

class HoloCard extends StatelessWidget {
  final dynamic note;
  final bool isLocked;
  final int index;
  final VoidCallback onDelete;

  const HoloCard({super.key, required this.note, required this.isLocked, required this.index, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(note.id),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      child: GestureDetector(
        onLongPress: () => HapticFeedback.heavyImpact(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: note.color.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(color: note.color.withOpacity(0.05), blurRadius: 15, spreadRadius: 0),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: note.color.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(note.tag, style: GoogleFonts.spaceMono(fontSize: 9, color: note.color)),
                        ),
                        Icon(Icons.more_horiz, size: 16, color: Colors.white30),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    Text(
                      isLocked ? _scrambleText(note.title) : note.title,
                      style: GoogleFonts.orbitron(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white,
                        shadows: isLocked ? [] : [Shadow(color: note.color.withOpacity(0.5), blurRadius: 5)]
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    if (isLocked)
                      Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(child: Text("ENCRYPTED", style: GoogleFonts.spaceMono(fontSize: 10, color: Colors.redAccent, letterSpacing: 2))),
                      )
                    else
                      Text(
                        note.content,
                        style: GoogleFonts.shareTechMono(fontSize: 12, color: Colors.white70, height: 1.4),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                    const SizedBox(height: 10),
                    Text(
                      DateFormat('MM.dd.yy • HH:mm').format(note.createdAt),
                      style: GoogleFonts.spaceMono(fontSize: 8, color: Colors.white24),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.2, end: 0),
      ),
    );
  }

  String _scrambleText(String text) {
    const chars = "*%#@&!01";
    // DÜZELTME: Random için doğru import
    return List.generate(text.length, (index) => chars[Random().nextInt(chars.length)]).join();
  }
}

class GlitchText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const GlitchText({super.key, required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(text, style: style.copyWith(color: Colors.red.withOpacity(0.5)))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .move(begin: const Offset(-1, 0), end: const Offset(1, 0), duration: 200.ms),
        Text(text, style: style.copyWith(color: Colors.blue.withOpacity(0.5)))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .move(begin: const Offset(1, 0), end: const Offset(-1, 0), duration: 300.ms),
        Text(text, style: style),
      ],
    );
  }
}

class MatrixRainPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  MatrixRainPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.15)..style = PaintingStyle.fill;
    
    double width = size.width;
    double height = size.height;
    int columns = 30; 
    double colWidth = width / columns;

    for (int i = 0; i < columns; i++) {
      double speed = 1.0 + (i % 5) * 0.5;
      double dropHeight = (animationValue * speed * height) % height;
      dropHeight = (dropHeight + (i * 50)) % height;

      double x = i * colWidth;
      
      final rect = Rect.fromLTWH(x + colWidth/2, dropHeight - 50, 2, 50);
      final gradient = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [color.withOpacity(0), color.withOpacity(0.5)]
      );
      paint.shader = gradient.createShader(rect);
      canvas.drawRect(rect, paint);
      
      paint.shader = null;
      paint.color = color.withOpacity(0.8);
      canvas.drawRect(Rect.fromLTWH(x + colWidth/2, dropHeight, 3, 5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant MatrixRainPainter oldDelegate) => true;
}