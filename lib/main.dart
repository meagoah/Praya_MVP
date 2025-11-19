import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'dart:ui'; // Pro ImageFilter (Blur)

// --- 1. DATA & STATE ---

enum FaithType { christian, muslim, atheist, spiritual, universal }

class AppState extends ChangeNotifier {
  int selectedIndex = 0; // Navigace
  int userPoints = 1240;
  int userLevel = 3;
  String userTitle = "Strážce";
  double stressLevel = 4.5; // 1-10
  
  // Mock Data pro Grafy
  final List<double> stressHistory = [8.0, 7.5, 6.2, 5.8, 5.0, 4.5, 4.2];
  final List<int> activityHistory = [2, 4, 5, 8, 12, 15, 18];

  // Theme
  Color get primaryColor => const Color(0xFF6C63FF); // Modern Purple
  Color get accentColor => const Color(0xFF00D2FF); // Cyan

  void setIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void addPoints(int points) {
    userPoints += points;
    notifyListeners();
  }
}

// --- 2. UI COMPONENTS (DESIGN SYSTEM) ---

class GlassCard extends StatelessWidget {
  final Widget child;
  final double opacity;
  final EdgeInsets padding;

  const GlassCard({super.key, required this.child, this.opacity = 0.1, this.padding = const EdgeInsets.all(20)});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }
}

// --- 3. HLAVNÍ STRUKTURA ---

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const PrayApp(),
    ),
  );
}

class PrayApp extends StatelessWidget {
  const PrayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrayApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF05050A),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(primary: Color(0xFF6C63FF)),
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    
    // Definice stránek podle tvých URL
    final List<Widget> pages = [
      const DashboardHome(),      // /dashboard (Feed + Quick stats)
      const JourneyScreen(),      // /journey (Tree + Path)
      const InsightsScreen(),     // /insights (Research graphs)
      const CharityScreen(),      // /charity (Impact)
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Ambient Background
          Positioned(top: -100, left: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purple.withValues(alpha: 0.2), boxShadow: [BoxShadow(blurRadius: 150, color: Colors.purple)]))),
          Positioned(bottom: -100, right: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.withValues(alpha: 0.2), boxShadow: [BoxShadow(blurRadius: 150, color: Colors.blue)]))),
          
          // Content
          SafeArea(child: pages[state.selectedIndex]),
        ],
      ),
      bottomNavigationBar: _buildModernNavBar(context, state),
    );
  }

  Widget _buildModernNavBar(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.black.withValues(alpha: 0.8), // Poloprůhledná lišta
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Icons.grid_view, "Home", 0, state),
          _navItem(context, Icons.account_tree_outlined, "Journey", 1, state),
          _navItem(context, Icons.bar_chart, "Insights", 2, state),
          _navItem(context, Icons.volunteer_activism, "Charity", 3, state),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, int index, AppState state) {
    bool isSelected = state.selectedIndex == index;
    return GestureDetector(
      onTap: () => state.setIndex(index),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF00D2FF) : Colors.white54),
            if (isSelected) Text(label, style: const TextStyle(fontSize: 10, color: Colors.white))
          ],
        ),
      ),
    );
  }
}

// --- 4. OBRAZOVKY (PAGES) ---

// A. DASHBOARD (Home)
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Vítej zpět, Poutníku", style: GoogleFonts.outfit(fontSize: 14, color: Colors.white54)),
                Text("Dashboard", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              ]),
              const CircleAvatar(backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=11"), radius: 25),
            ],
          ),
          const SizedBox(height: 30),

          // Stats Grid
          Row(children: [
            Expanded(child: _statCard("Modlitby", "124", Icons.favorite, Colors.pink)),
            const SizedBox(width: 15),
            Expanded(child: _statCard("Streak", "12 Dní", Icons.local_fire_department, Colors.orange)),
          ]),
          const SizedBox(height: 15),
          
          // Active Prayer Feed (Mini)
          Text("Aktuální Proud", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          _prayerCard("Maria (BR)", "Prosím o zdraví pro mé děti...", 45),
          _prayerCard("John (US)", "Děkuji za sílu v práci.", 12),
          _prayerCard("Poutník (CZ)", "Klid pro mou mysl.", 89),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _prayerCard(String author, String text, int likes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
             CircleAvatar(child: Text(author[0]), radius: 15, backgroundColor: Colors.white10),
             const SizedBox(width: 15),
             Expanded(child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                 Text(text, style: const TextStyle(color: Colors.white70)),
               ],
             )),
             Column(children: [
               const Icon(Icons.light_mode, size: 16, color: Colors.amber),
               Text(likes.toString(), style: const TextStyle(fontSize: 10)),
             ])
          ],
        ),
      ),
    );
  }
}

// B. JOURNEY (Profile & Tree)
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text("Tvoje Cesta", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
          Text("Level 3: Strážce", style: GoogleFonts.outfit(fontSize: 16, color: const Color(0xFF00D2FF))),
          
          const SizedBox(height: 40),
          
          // CENTRAL TREE VISUALIZATION
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow Background
              Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.4), blurRadius: 60)])),
              // Tree Icon (Growing)
              const Icon(Icons.park, size: 180, color: Colors.white).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 3000.ms, color: const Color(0xFF00D2FF)),
              // Orbiting Particles (Simple simulation)
              Positioned(top: 0, child: const Icon(Icons.star, size: 10, color: Colors.yellow).animate(onPlay: (c) => c.repeat()).moveY(begin: 0, end: 10, duration: 1000.ms)),
            ],
          ),
          
          const SizedBox(height: 50),
          
          // PROGRESS PATH (Timeline)
          Container(
            padding: const EdgeInsets.only(left: 20),
            decoration: const BoxDecoration(border: Border(left: BorderSide(color: Colors.white24, width: 2))),
            child: Column(
              children: [
                _pathNode("Světlonoš (Lvl 10)", false),
                _pathNode("Strážce (Lvl 3) - SOUČASNÝ", true),
                _pathNode("Hledač (Lvl 2)", true),
                _pathNode("Poutník (Lvl 1)", true),
              ],
            ),
          )
        ],
      ).animate().slideY(begin: 0.1, end: 0),
    );
  }

  Widget _pathNode(String title, bool completed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Row(
        children: [
          // Dot on the timeline
          Container(
            margin: const EdgeInsets.only(left: -25), // Pull back to line
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: completed ? const Color(0xFF00D2FF) : Colors.grey,
              shape: BoxShape.circle,
              boxShadow: completed ? [const BoxShadow(color: Color(0xFF00D2FF), blurRadius: 10)] : [],
            ),
          ),
          const SizedBox(width: 20),
          // Card
          Expanded(
            child: GlassCard(
              opacity: completed ? 0.1 : 0.05,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(color: completed ? Colors.white : Colors.white38)),
                  if(completed) const Icon(Icons.check, color: Color(0xFF00D2FF), size: 16)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// C. INSIGHTS (Research & Graphs)
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Vhledy & Data", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Jak modlitba ovlivňuje tvůj klid.", style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 30),

          // CHART 1: Stress Reduction
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Hladina Stresu (Posledních 7 dní)", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: state.stressHistory.map((val) {
                      return Tooltip(
                        message: "Stress: $val",
                        child: Container(
                          width: 30,
                          height: val * 15, // Scale for visual
                          decoration: BoxDecoration(
                            color: Color.lerp(Colors.green, Colors.red, val/10),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                const Text("-35% stresu od začátku používání", style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // CHART 2: Global Impact
           GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Globální Síla", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("12,450 modliteb dnes vysláno do světa.", style: TextStyle(fontSize: 20, color: Colors.amber)),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: 0.7, backgroundColor: Colors.white10, color: Colors.amber),
                const SizedBox(height: 5),
                const Text("70% k dennímu cíli komunity", style: TextStyle(fontSize: 10, color: Colors.white30)),
              ],
            ),
          ),
        ],
      ).animate().slideX(begin: 0.1, end: 0),
    );
  }
}

// D. CHARITY (Impact)
class CharityScreen extends StatelessWidget {
  const CharityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Tvůj Dopad", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Modlitba se mění v pomoc.", style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 30),

          // Wallet
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text("Vygenerováno pro Charitu", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 5),
                const Text("450 Kč", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {}, 
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black26, elevation: 0),
                  child: const Text("Spravovat Příspěvky")
                )
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          const Text("Podporované Projekty", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          
          _charityCard("Voda pro Afriku", "Pomocí modlitebních bodů jsme zajistili 120l vody.", 0.6),
          _charityCard("Vzdělání dětí", "Knihy a pomůcky pro sirotčinec.", 0.3),
          _charityCard("Oprava Kostela", "Lokální podpora komunity.", 0.85),

        ],
      ).animate().fadeIn(),
    );
  }

  Widget _charityCard(String title, String desc, double progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Icon(Icons.arrow_forward, size: 16, color: Colors.white54),
            ]),
            const SizedBox(height: 5),
            Text(desc, style: const TextStyle(fontSize: 12, color: Colors.white54)),
            const SizedBox(height: 15),
            LinearProgressIndicator(value: progress, backgroundColor: Colors.white10, color: const Color(0xFF00D2FF)),
          ],
        ),
      ),
    );
  }
}