import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'dart:ui';

// --- 1. CORE LOGIC & STATE ---

class FeedItem {
  String id;
  String author;
  String country;
  String text;
  int likes;
  bool isLiked;
  FeedItem(this.id, this.author, this.country, this.text, this.likes, {this.isLiked = false});
}

class AppState extends ChangeNotifier {
  int navIndex = 0;
  
  // USER STATS
  int auraPoints = 2450;
  int level = 5; // Hledač
  double currentStress = 0.5; // 0.0 (Klid) až 1.0 (Stres)
  
  // DATA
  List<FeedItem> feed = [
    FeedItem("1", "Maria", "BR", "Můj syn má zítra operaci. Potřebuji cítit, že v tom nejsem sama.", 342),
    FeedItem("2", "David", "CZ", "Děkuji za sílu odpustit otci. Cítím obrovskou úlevu.", 890),
    FeedItem("3", "Aisha", "AE", "Hledám světlo v temném období.", 120),
  ];

  List<String> chatHistory = [
    "Aura: Vítám tě. Cítím z tebe dnes napětí. Jak ti mohu posloužit?",
  ];

  // DYNAMIC THEME ENGINE (Vědecký podklad: Barvy ovlivňují psychiku)
  Color get moodColor {
    // Interpolace od Azurové (Klid) po Rudou (Stres)
    return Color.lerp(const Color(0xFF00D2FF), const Color(0xFFFF4B4B), currentStress)!;
  }

  void setIndex(int i) { navIndex = i; notifyListeners(); }

  void updateStress(double val) {
    currentStress = val;
    notifyListeners(); // Okamžitě překreslí celou aplikaci
  }

  void dischargePrayer(String id) {
    // Simulace odeslání energie
    var item = feed.firstWhere((e) => e.id == id);
    item.likes++;
    item.isLiked = true;
    auraPoints += 15;
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void sendMessage(String text) {
    chatHistory.add("Ty: $text");
    notifyListeners();
    Future.delayed(1500.ms, () {
      chatHistory.add("Aura: Rozumím. Tvá slova rezonují. Zpracovávám tvou emoci...");
      notifyListeners();
    });
  }
}

// --- 2. VISUAL COMPONENTS (The "Juice") ---

class LivingBackground extends StatelessWidget {
  const LivingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    
    // Pozadí reaguje na stres uživatele
    return Stack(
      children: [
        // Base Void
        Container(color: const Color(0xFF05050A)),
        
        // Mood Light 1 (Breathing)
        AnimatedPositioned(
          duration: 2000.ms,
          top: state.currentStress * -50, // Stres posouvá světlo
          left: -100,
          child: AnimatedContainer(
            duration: 1000.ms,
            width: 500, height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: state.moodColor.withValues(alpha: 0.15),
              boxShadow: [BoxShadow(color: state.moodColor, blurRadius: 120 + (state.currentStress * 100))]
            ),
          ).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.2, 1.2), duration: 4000.ms),
        ),

        // Mood Light 2
        Positioned(
          bottom: -100, right: -100,
          child: AnimatedContainer(
            duration: 1000.ms,
            width: 400, height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purpleAccent.withValues(alpha: 0.1),
              boxShadow: [BoxShadow(color: Colors.purpleAccent.withValues(alpha: 0.2), blurRadius: 150)]
            ),
          ).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.3, 1.3), duration: 5000.ms),
        ),
        
        // Noise Grain (Texture)
        Opacity(opacity: 0.03, child: Container(decoration: const BoxDecoration(image: DecorationImage(image: NetworkImage("https://www.transparenttextures.com/patterns/stardust.png"), repeat: ImageRepeat.repeat)))),
      ],
    );
  }
}

class GlassPanel extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool glow;
  
  const GlassPanel({super.key, required this.child, this.onTap, this.glow = false});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AnimatedContainer(
            duration: 500.ms,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: glow ? state.moodColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08)),
              boxShadow: glow ? [BoxShadow(color: state.moodColor.withValues(alpha: 0.2), blurRadius: 30)] : []
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// --- 3. MAIN ENTRY ---

void main() {
  runApp(ChangeNotifierProvider(create: (_) => AppState(), child: const PrayApp()));
}

class PrayApp extends StatelessWidget {
  const PrayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme)),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return Scaffold(
      body: Stack(
        children: [
          const LivingBackground(), // 1. Vrstva: Živý organismus
          SafeArea(
            child: IndexedStack( // 2. Vrstva: Obsah
              index: state.navIndex,
              children: const [
                HomeFeedScreen(),
                JourneyScreen(),
                StatsScreen(),
              ],
            ),
          ),
          // 3. Vrstva: Plovoucí Navigace (Futuristická)
          Align(alignment: Alignment.bottomCenter, child: _buildDock(context, state)),
          
          // 4. Vrstva: Aura AI (Always on top)
          Positioned(
            bottom: 100, right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () => _openAura(context),
              child: const Icon(Icons.auto_awesome, color: Colors.white).animate(onPlay: (c)=>c.repeat()).shimmer(duration: 2000.ms, color: state.moodColor),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
          )
        ],
      ),
    );
  }

  Widget _buildDock(BuildContext context, AppState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20)]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dockItem(Icons.grid_view_rounded, 0, state),
              const SizedBox(width: 20),
              _dockItem(Icons.fingerprint, 1, state), // Unikátní ikona pro Journey
              const SizedBox(width: 20),
              _dockItem(Icons.pie_chart_outline, 2, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dockItem(IconData icon, int index, AppState state) {
    bool active = state.navIndex == index;
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); state.setIndex(index); },
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          shape: BoxShape.circle
        ),
        child: Icon(icon, color: active ? Colors.black : Colors.white54, size: 24),
      ),
    );
  }
}

// --- 4. SCREENS (THE CONTENT) ---

// A. HOME FEED - S "Haptickou modlitbou"
class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header s Biofeedbackem
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("PRAYA", style: GoogleFonts.cinzel(fontSize: 24, letterSpacing: 5, fontWeight: FontWeight.bold)),
                Text(state.currentStress > 0.7 ? "Dýchej..." : "Vítej doma.", style: TextStyle(color: state.moodColor, fontSize: 12)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
                child: Text("${state.auraPoints} ✨", style: const TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
          
          const SizedBox(height: 40),
          
          // MOOD SLIDER (Nejdůležitější prvek pro výzkum)
          GlassPanel(
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                   const Text("Tvůj vnitřní stav (Research)", style: TextStyle(fontSize: 12, color: Colors.white54)),
                   Icon(Icons.circle, size: 8, color: state.moodColor).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(begin: const Offset(0.5,0.5), end: const Offset(1.5, 1.5)),
                ]),
                const SizedBox(height: 15),
                SliderTheme(
                  data: SliderThemeData(trackHeight: 10, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12), activeTrackColor: state.moodColor, thumbColor: Colors.white),
                  child: Slider(
                    value: state.currentStress,
                    onChanged: (v) => state.updateStress(v),
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                  Text("Klid", style: TextStyle(fontSize: 10, color: Colors.white30)),
                  Text("Bouře", style: TextStyle(fontSize: 10, color: Colors.white30)),
                ]),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          Text("Proud Energie", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          // THE CARDS
          ...state.feed.map((item) => _buildMagicCard(context, item, state)).toList(),
          
          const SizedBox(height: 100), // Space for dock
        ],
      ).animate().fadeIn(duration: 800.ms),
    );
  }

  Widget _buildMagicCard(BuildContext context, FeedItem item, AppState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassPanel(
        glow: item.isLiked,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(item.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 8),
              Text("• ${item.country}", style: const TextStyle(color: Colors.white38, fontSize: 12)),
              const Spacer(),
              if (item.isLiked) const Icon(Icons.check, color: Colors.white, size: 16).animate().scale(),
            ]),
            const SizedBox(height: 15),
            Text(item.text, style: const TextStyle(fontSize: 18, height: 1.4, color: Colors.white70)),
            const SizedBox(height: 20),
            
            // INTERACTIVE PRAYER BUTTON
            GestureDetector(
              onLongPress: () => state.dischargePrayer(item.id),
              child:  AnimatedContainer(
                duration: 500.ms,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: item.isLiked ? [state.moodColor, Colors.purple] : [Colors.white10, Colors.white10]),
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Center(
                  child: item.isLiked 
                    ? const Text("ENERGIE ODESLÁNA", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white))
                    : const Text("PODRŽ PRO PODPORU", style: TextStyle(fontSize: 12, color: Colors.white54)),
                ),
              ),
            )
          ],
        ),
      ).animate().slideY(begin: 0.2, end: 0),
    );
  }
}

// B. JOURNEY SCREEN (Gamification)
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text("Cesta Duše", style: GoogleFonts.cinzel(fontSize: 30)),
          const SizedBox(height: 40),
          
          // CENTRAL ARTIFACT (Tree + Planet)
          SizedBox(
            height: 350,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Orbiting Rings
                Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1))),
                Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1))),
                
                // The Living Tree
                Icon(Icons.park, size: 200, color: state.moodColor)
                  .animate(onPlay: (c)=>c.repeat(reverse: true))
                  .scale(begin: const Offset(1,1), end: const Offset(1.05, 1.05), duration: 3000.ms)
                  .shimmer(duration: 2000.ms, color: Colors.white),
                  
                // Floating Particles
                Positioned(top: 50, right: 80, child: _particle(Colors.amber)),
                Positioned(bottom: 80, left: 60, child: _particle(Colors.cyan)),
              ],
            ),
          ),
          
          GlassPanel(
            child: Column(
              children: [
                Text("Level 5: HLEDAČ", style: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.bold, color: state.moodColor)),
                const SizedBox(height: 10),
                const Text("Tvá konzistence otevírá nové obzory.", style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 20),
                LinearProgressIndicator(value: 0.7, backgroundColor: Colors.black, color: state.moodColor, minHeight: 10, borderRadius: BorderRadius.circular(5)),
                const SizedBox(height: 10),
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("2450 XP", style: TextStyle(fontSize: 12)),
                  Text("3000 XP", style: TextStyle(fontSize: 12, color: Colors.white38)),
                ])
              ],
            ),
          )
        ],
      ).animate().scale(),
    );
  }

  Widget _particle(Color color) {
    return Container(
      width: 8, height: 8, 
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 10)])
    ).animate(onPlay: (c)=>c.repeat(reverse: true)).moveY(begin: 0, end: -20, duration: 2000.ms);
  }
}

// C. STATS & RESEARCH
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Zde budou grafy (Insights)", style: TextStyle(color: Colors.white38)));
  }
}

// D. AURA MODAL
void _openAura(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => const AuraModal(),
  );
}

class AuraModal extends StatelessWidget {
  const AuraModal({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A15).withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: Colors.white10)
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 30),
            Icon(Icons.auto_awesome, size: 50, color: state.moodColor).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(begin: const Offset(0.8,0.8), end: const Offset(1.2, 1.2)),
            const SizedBox(height: 20),
            Text("AURA AI", style: GoogleFonts.cinzel(fontSize: 24, letterSpacing: 5)),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(30),
                children: state.chatHistory.map((msg) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(msg, style: TextStyle(color: msg.startsWith("Ty") ? Colors.white : state.moodColor, fontSize: 16)),
                )).toList(),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, left: 30, right: 30),
              child: TextField(
                onSubmitted: (val) => context.read<AppState>().sendMessage(val),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Napiš zprávu...",
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true, fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}