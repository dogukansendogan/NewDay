import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:new_day/features/wealth/wealth_provider.dart';
// KOMŞU İMPORT

class WealthScreen extends ConsumerStatefulWidget {
  const WealthScreen({super.key});

  @override
  ConsumerState<WealthScreen> createState() => _WealthScreenState();
}

class _WealthScreenState extends ConsumerState<WealthScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  
  // Formatlayıcı (Para Birimi)
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: "tr_TR", symbol: "₺", decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wealthProvider);
    final notifier = ref.read(wealthProvider.notifier);

    // Renk Paleti (Wealth Theme)
    const Color gold = Color(0xFFFFD700);
    const Color darkNavy = Color(0xFF051937);
    const Color emerald = Color(0xFF00C853);
    const Color crimson = Color(0xFFD50000);

    return Scaffold(
      backgroundColor: Colors.black,
      
      // EKLEME BUTONU (Floating Gold Coin)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionModal(context, notifier),
        backgroundColor: gold,
        elevation: 10,
        child: const Icon(Icons.add, color: Colors.black, size: 32),
      ).animate().scale(delay: 500.ms, curve: Curves.elasticOut),

      body: Stack(
        children: [
          // 1. ARKA PLAN (Lüks Gradyan)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.black, darkNavy, Colors.black],
                ),
              ),
            ),
          ),

          // 2. ALTIN TOZLU EFEKT (Canvas Painter)
          Positioned.fill(
            child: CustomPaint(painter: GoldDustPainter()),
          ),

          SafeArea(
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("WEALTH COMMAND", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14, letterSpacing: 2)),
                          Text("Finansal Durum", style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: gold)),
                        child: const Icon(Icons.account_balance_wallet, color: gold, size: 20),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- HOLOGRAFİK KART (MAIN BALANCE) ---
                _buildHoloCard(state, gold),

                const SizedBox(height: 30),

                // --- ÖZET İSTATİSTİK (GELİR / GİDER) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(child: _buildStatBox("GELİR", state.totalIncome, emerald, Icons.arrow_upward)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildStatBox("GİDER", state.totalExpense, crimson, Icons.arrow_downward)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- İŞLEM LİSTESİ BAŞLIĞI ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("SON İŞLEMLER", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const Icon(Icons.sort, color: Colors.white30),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // --- İŞLEM LİSTESİ ---
                Expanded(
                  child: state.transactions.isEmpty
                      ? Center(child: Text("Veri Yok", style: GoogleFonts.poppins(color: Colors.white30)))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                          itemCount: state.transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = state.transactions[index];
                            return _buildTransactionTile(transaction, notifier, index);
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

  // --- WIDGETLAR ---

  Widget _buildHoloCard(WealthState state, Color gold) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: gold.withOpacity(0.1), blurRadius: 30, spreadRadius: 5),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Stack(
            children: [
              // Kart Arka Plan Deseni
              Positioned(
                right: -50, top: -50,
                child: Icon(Icons.currency_bitcoin, size: 250, color: Colors.white.withOpacity(0.05)),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("TOPLAM VARLIK", style: GoogleFonts.spaceMono(color: gold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const Icon(Icons.wifi, color: Colors.white54, size: 20),
                      ],
                    ),
                    
                    // Ana Bakiye (Animasyonlu Sayaç)
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: state.totalBalance),
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeOutExpo,
                      builder: (context, value, child) {
                        return Text(
                          _currencyFormat.format(value),
                          style: GoogleFonts.orbitron(
                            fontSize: 36, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white,
                            shadows: [Shadow(color: gold, blurRadius: 10)]
                          ),
                        );
                      },
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("**** **** 8080", style: GoogleFonts.spaceMono(color: Colors.white54)),
                        Text("NEWDAY PLATINUM", style: GoogleFonts.orbitron(color: Colors.white30, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatBox(String label, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Icon(Icons.more_horiz, color: color.withOpacity(0.5), size: 16),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _currencyFormat.format(amount),
            style: GoogleFonts.spaceMono(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: color)),
        ],
      ),
    ).animate().scale(delay: 200.ms);
  }

  Widget _buildTransactionTile(dynamic t, dynamic notifier, int index) {
    final isExpense = t.isExpense;
    final color = isExpense ? const Color(0xFFD50000) : const Color(0xFF00C853);

    return Dismissible(
      key: Key(t.id),
      onDismissed: (_) => notifier.deleteTransaction(t.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpense ? Icons.shopping_bag_outlined : Icons.monetization_on_outlined,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                  Text(t.category, style: GoogleFonts.spaceMono(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ),
            Text(
              "${isExpense ? '-' : '+'}${_currencyFormat.format(t.amount)}",
              style: GoogleFonts.spaceMono(
                color: color, 
                fontWeight: FontWeight.bold,
                fontSize: 14
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.2, end: 0);
  }

  void _showTransactionModal(BuildContext context, dynamic notifier) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    bool isExpense = true;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
                left: 20, right: 20, top: 20
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A).withOpacity(0.9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("YENİ İŞLEM", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 20),
                  
                  // Tür Seçici (Gelir/Gider)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => isExpense = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isExpense ? Colors.redAccent : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.redAccent)
                            ),
                            child: Center(child: Text("GİDER", style: GoogleFonts.spaceMono(color: Colors.white, fontWeight: FontWeight.bold))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => isExpense = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isExpense ? Colors.greenAccent : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.greenAccent)
                            ),
                            child: Center(child: Text("GELİR", style: GoogleFonts.spaceMono(color: !isExpense ? Colors.black : Colors.white, fontWeight: FontWeight.bold))),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Tutar
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.orbitron(color: Colors.white, fontSize: 24),
                    decoration: const InputDecoration(
                      prefixText: "₺ ",
                      prefixStyle: TextStyle(color: Colors.white54, fontSize: 24),
                      hintText: "0.00",
                      hintStyle: TextStyle(color: Colors.white12),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Açıklama
                  TextField(
                    controller: titleCtrl,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Açıklama (Örn: Market)",
                      hintStyle: TextStyle(color: Colors.white38),
                      filled: true, fillColor: Colors.white10,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide.none),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (amountCtrl.text.isNotEmpty && titleCtrl.text.isNotEmpty) {
                          double amount = double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0.0;
                          notifier.addTransaction(titleCtrl.text, amount, isExpense, "Genel");
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("EKLE", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

// --- ALTIN TOZU EFEKTİ ---
class GoldDustPainter extends CustomPainter {
  final math.Random _rnd = math.Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (int i = 0; i < 50; i++) {
      paint.color = const Color(0xFFFFD700).withOpacity(_rnd.nextDouble() * 0.3);
      double x = _rnd.nextDouble() * size.width;
      double y = _rnd.nextDouble() * size.height;
      double r = _rnd.nextDouble() * 2;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}