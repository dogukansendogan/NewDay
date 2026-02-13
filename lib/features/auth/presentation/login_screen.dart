import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart'; // User tipi için
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:new_day/features/auth/data/auth_service.dart'; // Servisi çağırdık
import '../../home/presentation/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  Alignment _topAlignment = Alignment.topLeft;
  Alignment _bottomAlignment = Alignment.bottomRight;
  
  bool _isLoading = false; // Yükleniyor animasyonu için

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _bgController.addListener(() {
      setState(() {
        _topAlignment = Alignment(-1.0 + (_bgController.value * 2.0), -1.0);
        _bottomAlignment = Alignment(1.0 - (_bgController.value * 2.0), 1.0);
      });
    });
    
    // Eğer kullanıcı zaten giriş yapmışsa direkt ana sayfaya at
    _checkCurrentUser();
  }
  
  void _checkCurrentUser() {
    final user = ref.read(authServiceProvider).currentUser;
    if (user != null) {
      // Bir frame bekleyip sayfayı değiştir (Hata almamak için)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToHome(context);
      });
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  // --- GOOGLE GİRİŞ MANTIĞI ---
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true); // Yükleniyor...
    
    final user = await ref.read(authServiceProvider).signInWithGoogle();
    
    setState(() => _isLoading = false); // Yükleme bitti

    if (user != null) {
      // Başarılıysa geçiş yap
      if(mounted) _navigateToHome(context);
    } else {
      // Hata veya iptal durumu
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Giriş yapılamadı veya iptal edildi.")),
        );
      }
    }
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. ARKA PLAN
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _topAlignment,
                end: _bottomAlignment,
                colors: const [
                  Color(0xFF2E3192),
                  Color(0xFF1BFFFF),
                  Color(0xFFD4145A),
                  Color(0xFFFBB03B),
                ],
              ),
            ),
          ),

          // 2. PARTİKÜLLER
          Positioned(
            top: 100, left: 30,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 50, spreadRadius: 10)],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 3.seconds, begin: const Offset(1,1), end: const Offset(1.5, 1.5)),
          ),

          // 3. İÇERİK
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: const Icon(Icons.wb_sunny_rounded, size: 60, color: Colors.white),
                    ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.5, end: 0).shimmer(delay: 1.seconds, duration: 1.seconds),

                    const SizedBox(height: 30),

                    Text("NewDay", style: GoogleFonts.playfairDisplay(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2, shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 5))])).animate().fadeIn(delay: 300.ms).scale(),
                    const SizedBox(height: 10),
                    Text("Hayatını Yönet. Geleceği İnşa Et.", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, color: Colors.white.withOpacity(0.9), letterSpacing: 1.2, fontWeight: FontWeight.w300)).animate().fadeIn(delay: 500.ms),

                    const SizedBox(height: 60),

                    // CAM PANEL
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              // GOOGLE BUTONU
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  // BUTONA BASILINCA ARTIK GOOGLE ÇALIŞACAK
                                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: _isLoading 
                                    ? const CircularProgressIndicator() // Yükleniyorsa dönen halka
                                    : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.g_mobiledata, size: 36, color: Colors.blue),
                                        const SizedBox(width: 10),
                                        Text("Google ile Başla", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                ),
                              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.5, end: 0),

                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: OutlinedButton(
                                  onPressed: () => _navigateToHome(context),
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                  child: Text("Misafir Olarak Göz At", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                                ),
                              ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.5, end: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text("v1.0.0 • Dogu Software", style: GoogleFonts.poppins(fontSize: 12, color: Colors.white38)).animate().fadeIn(delay: 1500.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}