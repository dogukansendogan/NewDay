import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart'; // Font paketi
import 'package:new_day/core/theme/app_colors.dart';

class OasisScreen extends StatefulWidget {
  const OasisScreen({super.key});

  @override
  State<OasisScreen> createState() => _OasisScreenState();
}

class _OasisScreenState extends State<OasisScreen> with TickerProviderStateMixin {
  // --- AYARLAR DURUMU ---
  double _sessionDuration = 1.0; // Dakika cinsinden
  bool _hapticsEnabled = true;
  bool _bgMusicEnabled = true;

  // --- SAYFA DURUMU ---
  int _selectedMoodIndex = 2; 
  int _selectedSoundIndex = 0; 
  
  bool _isBreathingActive = false;
  String _breathText = "BAŞLAT"; // Daha kısa ve net
  Timer? _breathTimer;
  int _breathPhase = 0; 

  late AnimationController _bgController;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😔', 'label': 'Yorgun', 'color': const Color(0xFF78909C)},
    {'emoji': '😐', 'label': 'Nötr', 'color': const Color(0xFF8D6E63)},
    {'emoji': '😌', 'label': 'Huzurlu', 'color': const Color(0xFF26A69A)},
    {'emoji': '🤩', 'label': 'Enerjik', 'color': const Color(0xFFFF7043)},
    {'emoji': '🧘', 'label': 'Zen', 'color': const Color(0xFF5C6BC0)},
  ];

  final List<Map<String, dynamic>> _sounds = [
    {'icon': Icons.water_drop, 'label': 'Yağmur'},
    {'icon': Icons.forest, 'label': 'Orman'},
    {'icon': Icons.waves, 'label': 'Okyanus'},
    {'icon': Icons.nightlight_round, 'label': 'Gece'},
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathTimer?.cancel();
    _bgController.dispose();
    super.dispose();
  }

  void _toggleBreathing() {
    setState(() {
      _isBreathingActive = !_isBreathingActive;
    });

    if (_isBreathingActive) {
      _runBreathCycle();
    } else {
      _breathTimer?.cancel();
      setState(() {
        _breathText = "BASLAT";
        _breathPhase = 0;
      });
    }
  }

  void _runBreathCycle() {
    setState(() { _breathPhase = 1; _breathText = "NEFES AL"; });

    _breathTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        if (_breathPhase == 1) {
          _breathPhase = 2; 
          _breathText = "TUT";
        } else if (_breathPhase == 2) {
          _breathPhase = 3; 
          _breathText = "VER";
        } else {
          _breathPhase = 1; 
          _breathText = "NEFES AL";
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          Container(color: Colors.white.withOpacity(0.3)), // Buzlu Cam Katmanı

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 30),
                  
                  Text("RUHUN NASIL?", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Colors.black45)),
                  const SizedBox(height: 15),
                  _buildMoodSelector(),
                  
                  const SizedBox(height: 40),
                  
                  Center(child: _buildBreathingOrb()),
                  
                  const SizedBox(height: 40),

                  Text("ORTAM SESİ", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Colors.black45)),
                  const SizedBox(height: 15),
                  _buildSoundSelector(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET PARÇALARI ---

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -100 + (_bgController.value * 50),
              left: -50,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE0F7FA).withOpacity(0.6),
                  boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 100, spreadRadius: 50)],
                ),
              ),
            ),
            Positioned(
              bottom: -100 - (_bgController.value * 50),
              right: -50,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFCE4EC).withOpacity(0.6),
                  boxShadow: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.2), blurRadius: 100, spreadRadius: 50)],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Oasis", style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF2D3142))),
            const SizedBox(height: 4),
            Text("Kendine bir mola ver.", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
          ],
        ),
        
        // --- AYARLAR BUTONU (ARTIK ÇALIŞIYOR) ---
        GestureDetector(
          onTap: () => _showSettingsModal(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.black54),
          ),
        )
      ],
    ).animate().fadeIn().slideY(begin: -0.5, end: 0);
  }

  // --- YENİ AYARLAR PENCERESİ ---
  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Arka planı transparan yapıyoruz ki köşeler yuvarlansın
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 20),
                  Text("Oasis Ayarları", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  
                  // 1. Süre Ayarı Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Seans Süresi", style: GoogleFonts.poppins(fontSize: 16)),
                      Text("${_sessionDuration.toInt()} dk", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  Slider(
                    value: _sessionDuration,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primary.withOpacity(0.2),
                    onChanged: (val) {
                      setModalState(() => _sessionDuration = val);
                      setState(() => _sessionDuration = val); // Ana sayfayı da güncelle
                    },
                  ),

                  const SizedBox(height: 10),
                  
                  // 2. Titreşim Ayarı
                  
                  SwitchListTile(
                    title: Text("Dokunsal Geri Bildirim", style: GoogleFonts.poppins(fontSize: 16)),
                    subtitle: Text("Nefes alırken titret", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                    value: _hapticsEnabled,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setModalState(() => _hapticsEnabled = val);
                      setState(() => _hapticsEnabled = val);
                    },
                  ),
                  
                  // 3. Arka Plan Sesi
                  SwitchListTile(
                    title: Text("Arka Plan Sesleri", style: GoogleFonts.poppins(fontSize: 16)),
                    value: _bgMusicEnabled,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setModalState(() => _bgMusicEnabled = val);
                      setState(() => _bgMusicEnabled = val);
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildMoodSelector() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _moods.length,
        clipBehavior: Clip.none,
        itemBuilder: (context, index) {
          final mood = _moods[index];
          final isSelected = _selectedMoodIndex == index;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedMoodIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.only(right: 16),
              width: isSelected ? 75 : 60,
              decoration: BoxDecoration(
                color: isSelected ? (mood['color'] as Color) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? (mood['color'] as Color).withOpacity(0.4) : Colors.grey.withOpacity(0.1),
                    blurRadius: isSelected ? 15 : 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(mood['emoji'], style: TextStyle(fontSize: isSelected ? 32 : 24)),
                  const SizedBox(height: 4),
                  if (isSelected)
                    Text(mood['label'], style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))
                        .animate().fadeIn(),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 200.ms).slideX();
  }

  Widget _buildBreathingOrb() {
    double size = 200;
    Color orbColor = Colors.white;
    List<BoxShadow> shadows = [];

    if (_isBreathingActive) {
      if (_breathPhase == 1) { 
        size = 280;
        orbColor = const Color(0xFFE0F2F1); 
        shadows = [BoxShadow(color: Colors.teal.withOpacity(0.4), blurRadius: 50, spreadRadius: 10)];
      } else if (_breathPhase == 2) { 
        size = 290;
        orbColor = const Color(0xFFE0F7FA);
        shadows = [BoxShadow(color: Colors.cyan.withOpacity(0.5), blurRadius: 60, spreadRadius: 20)];
      } else if (_breathPhase == 3) { 
        size = 200;
        orbColor = Colors.white;
        shadows = [BoxShadow(color: Colors.blueGrey.withOpacity(0.2), blurRadius: 30, spreadRadius: 5)];
      }
    } else {
      shadows = [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 40, spreadRadius: 0)];
    }

    return GestureDetector(
      onTap: _toggleBreathing,
      child: AnimatedContainer(
        duration: const Duration(seconds: 4), 
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: orbColor,
          boxShadow: shadows,
          gradient: _isBreathingActive 
            ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, orbColor])
            : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isBreathingActive)
                 const Icon(Icons.play_arrow_rounded, size: 40, color: AppColors.primary).animate().scale(duration: 1.seconds, curve: Curves.easeInOut).then().scale(begin: const Offset(1,1), end: const Offset(1.2, 1.2)),
              
              const SizedBox(height: 10),
              
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _breathText,
                  key: ValueKey(_breathText),
                  // İŞTE YENİ PREMIUM YAZI STİLİ:
                  style: GoogleFonts.lato( 
                    fontSize: 20, 
                    fontWeight: FontWeight.w300, // İnce (Light) font
                    color: _isBreathingActive ? AppColors.textPrimary : AppColors.primary,
                    letterSpacing: 4.0, // Harf aralığı geniş
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_sounds.length, (index) {
        final sound = _sounds[index];
        final isSelected = _selectedSoundIndex == index;

        return GestureDetector(
          onTap: () => setState(() => _selectedSoundIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2D3142) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
              boxShadow: isSelected 
                  ? [BoxShadow(color: const Color(0xFF2D3142).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] 
                  : [],
            ),
            child: Column(
              children: [
                Icon(
                  sound['icon'], 
                  color: isSelected ? Colors.white : Colors.grey,
                  size: 24
                ),
                const SizedBox(height: 6),
                Text(
                  sound['label'], 
                  style: GoogleFonts.poppins(fontSize: 10, color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.w600)
                ),
              ],
            ),
          ),
        );
      }),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }
}