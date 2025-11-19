import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'dart:ui';

// --- 1. DATA & STATE MODEL ---

class FeedItem {
  String author;
  String text;
  int likes;
  String timeAgo;
  FeedItem(this.author, this.text, this.likes, this.timeAgo);
}

class ChatMessage {
  final String text;
  final bool isMe;
  ChatMessage(this.text, this.isMe);
}

class AppState extends ChangeNotifier {
  int selectedIndex = 0;
  
  // Gamification Stats
  int userPoints = 1240;
  int userLevel = 3;
  double stressLevel = 5.0;
  
  // Data Stores
  List<ChatMessage> auraMessages = [
    ChatMessage("Vítej, Poutníku. Cítím, že tvůj strom dnes potřebuje světlo. Jak ti mohu pomoci?", false),
  ];
  
  List<FeedItem> feedItems = [
    FeedItem("Maria (Brazílie)", "Prosím o sílu pro mou rodinu v těchto těžkých časech.", 45, "2h"),
    FeedItem("John (USA)", "Děkuji za novou pracovní příležitost. Zázraky se dějí.", 128, "4h"),
    FeedItem("Anonym (CZ)", "Hledám klid v duši před zkouškovým obdobím.", 12, "5m"),
  ];

  // Logic
  void setIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void addPost(String text, double stress) {
    feedItems.insert(0, FeedItem("Ty (Právě teď)", text, 0, "Teď"));
    userPoints += 50; // Odměna za odvahu
    stressLevel = stress;
    _checkLevelUp();
    notifyListeners();
  }

  void addPoints(int amount) {
    userPoints += amount;
    _checkLevelUp();
    notifyListeners();
  }

  void sendMessageToAura(String text) {
    auraMessages.add(ChatMessage(text, true));
    notifyListeners();
    
    // Simulace AI odpovědi
    Future.delayed(2000.ms, () {
      auraMessages.add(ChatMessage("Rozumím ti. Tvá slova byla vyslyšena. Přidávám ti 5 bodů Aury za sdílení.", false));
      addPoints(5);
      notifyListeners();
    });
  }

  void _checkLevelUp() {
    // Jednoduchá logika: Level up každých 500 bodů
    int calculatedLevel = (userPoints / 500).floor() + 1;
    if (calculatedLevel > userLevel) {
      userLevel = calculatedLevel;
      // Tady by se mohlo spustit konfety
    }
  }
  
  String get userTitle {
    if (userLevel < 2) return "Poutník";
    if (userLevel < 5) return "Hledač";
    if (userLevel < 10) return "Strážce";
    return "Světlonoš";
  }
}

// --- 2. DESIGN SYSTEM (GLASS UI) ---

class GlassCard extends StatelessWidget {
  final Widget child;
  final double opacity;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const GlassCard({super.key, required this.child, this.opacity = 0.05, this.padding = const EdgeInsets.all(20), this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: opacity),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 2)]
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// --- 3. MAIN APP ---

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
        scaffoldBackgroundColor: const Color(0xFF05050A), // Deep Void Black
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(primary: Color(0xFF6C63FF), secondary: Color(0xFF00D2FF)),
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
    
    // DŮLEŽITÉ: Tady definujeme skutečné obrazovky, ne placeholdery
    final List<Widget> pages = [
      const DashboardScreen(),  // 0
      const JourneyScreen(),    // 1 (Strom)
      const CreateScreen(),     // 2 (Plus)
      const InsightsScreen(),   // 3 (Grafy)
      const CharityScreen(),    // 4 (Charita)
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false, // Aby klávesnice nerozbila layout
      body: Stack(
        children: [
          // 1. Ambientní Pozadí (Animované)
          Positioned(top: -100, left: -50, child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF6C63FF).withValues(alpha: 0.15), boxShadow: [BoxShadow(blurRadius: 150, color: const Color(0xFF6C63FF))]))),
          Positioned(bottom: -100, right: -50, child: Container(width: 350, height: 350, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00D2FF).withValues(alpha: 0.1), boxShadow: [BoxShadow(blurRadius: 150, color: const Color(0xFF00D2FF))]))),
          
          // 2. Obsah Stránky
          SafeArea(child: pages[state.selectedIndex]),
          
          // 3. Navigace (Dole)
          Align(alignment: Alignment.bottomCenter, child: _buildGlassNavBar(context, state)),
        ],
      ),
      
      // 4. Aura AI (FAB) - Zobrazuje se všude kromě "Create" obrazovky
      floatingActionButton: state.selectedIndex != 2 ? Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Nad navigací
        child: FloatingActionButton(
          onPressed: () => _showAuraChat(context),
          backgroundColor: const Color(0xFF6C63FF),
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.auto_awesome, color: Colors.white).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1)),
        ),
      ) : null,
    );
  }

  Widget _buildGlassNavBar(BuildContext context, AppState state) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF101015).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 5)]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.grid_view_rounded, 0, state),
          _navItem(Icons.park_outlined, 1, state),
          _centerNavItem(context, state),
          _navItem(Icons.bar_chart_rounded, 3, state),
          _navItem(Icons.volunteer_activism_rounded, 4, state),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index, AppState state) {
    bool isSelected = state.selectedIndex == index;
    return GestureDetector(
      onTap: () => state.setIndex(index),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white10 : Colors.transparent,
          shape: BoxShape.circle
        ),
        child: Icon(icon, color: isSelected ? const Color(0xFF00D2FF) : Colors.white38, size: 24),
      ),
    );
  }

  Widget _centerNavItem(BuildContext context, AppState state) {
    return GestureDetector(
      onTap: () => state.setIndex(2),
      child: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [Color(0xFF00D2FF), Color(0xFF6C63FF)]),
          boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.5), blurRadius: 15)]
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ).animate(target: state.selectedIndex == 2 ? 1 : 0).scale(end: const Offset(1.1, 1.1)),
    );
  }
}

// --- 4. OBRAZOVKY (SCREENS) ---

// A. DASHBOARD (Plně funkční feed)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // Bottom padding for Nav
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Řeka Naděje", style: GoogleFonts.cinzel(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("Společně silnější.", style: GoogleFonts.outfit(color: Colors.white54)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF6C63FF).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  const Icon(Icons.bolt, color: Colors.amber, size: 16),
                  const SizedBox(width: 5),
                  Text("${state.userPoints}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ]),
              )
            ],
          ),
          const SizedBox(height: 25),
          
          // Stories / Highlights (Horizontal)
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _storyCard("Můj Strom", Icons.park, Colors.green, () => state.setIndex(1)),
                _storyCard("Výzkum", Icons.science, Colors.blue, () => state.setIndex(3)),
                _storyCard("Charita", Icons.favorite, Colors.pink, () => state.setIndex(4)),
              ],
            ),
          ),
          const SizedBox(height: 25),
          
          Text("Aktuální proud", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 15),
          
          // FEED LIST
          ...state.feedItems.map((item) => _buildFeedItem(context, item, state)).toList(),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _storyCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70))
          ],
        ),
      ),
    );
  }

  Widget _buildFeedItem(BuildContext context, FeedItem item, AppState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 16, backgroundColor: Colors.white10, child: Text(item.author[0], style: const TextStyle(color: Colors.white))),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.author, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(item.timeAgo, style: const TextStyle(fontSize: 10, color: Colors.white38)),
                ]),
                const Spacer(),
                const Icon(Icons.more_horiz, color: Colors.white24),
              ],
            ),
            const SizedBox(height: 15),
            Text(item.text, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white70)),
            const SizedBox(height: 15),
            const Divider(color: Colors.white10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                     state.addPoints(5);
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Zapáleno! +5 bodů"), duration: Duration(milliseconds: 500)));
                  },
                  child: Row(children: [
                    const Icon(Icons.light_mode_outlined, size: 18, color: Colors.amber),
                    const SizedBox(width: 5),
                    Text("Zapálit (${item.likes})", style: const TextStyle(color: Colors.white54)),
                  ]),
                ),
                const Icon(Icons.volunteer_activism, size: 18, color: Colors.white24),
              ],
            )
          ],
        ),
      ),
    ).animate().slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
}

// B. JOURNEY SCREEN (STROM ŽIVOTA - FUNKČNÍ)
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text("Tvoje Cesta", style: GoogleFonts.cinzel(fontSize: 30, fontWeight: FontWeight.bold)),
          Text("Level ${state.userLevel}: ${state.userTitle}", style: const TextStyle(color: Color(0xFF00D2FF), letterSpacing: 2)),
          
          const SizedBox(height: 40),
          
          // --- STROM ŽIVOTA (VIZUALIZACE) ---
          SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Záře
                Container(
                  width: 200 + (state.userLevel * 10).toDouble(), 
                  height: 200 + (state.userLevel * 10).toDouble(),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF6C63FF).withValues(alpha: 0.2), boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.3), blurRadius: 60)]),
                ).animate(onPlay: (c)=>c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.2, 1.2), duration: 3000.ms),
                
                // Samotný strom
                Icon(
                  Icons.park, 
                  size: 180 + (state.userLevel * 5).toDouble(), 
                  color: state.userLevel > 5 ? const Color(0xFF00D2FF) : Colors.greenAccent
                ).animate().shimmer(duration: 2000.ms, color: Colors.white54),
                
                // Částice (Particles)
                Positioned(top: 20, right: 50, child: const Icon(Icons.star, size: 8, color: Colors.amber).animate(onPlay: (c)=>c.repeat()).moveY(begin: 0, end: -20, duration: 2000.ms)),
                Positioned(bottom: 40, left: 60, child: const Icon(Icons.circle, size: 5, color: Colors.white).animate(onPlay: (c)=>c.repeat()).moveY(begin: 0, end: -30, duration: 2500.ms)),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("${state.userPoints} XP", style: const TextStyle(color: Colors.white70)),
                  Text("${state.userLevel * 500} XP", style: const TextStyle(color: Colors.white38)),
                ]),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (state.userPoints % 500) / 500, 
                  backgroundColor: Colors.white10, 
                  color: const Color(0xFF00D2FF),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Milestones (Timeline)
          Align(alignment: Alignment.centerLeft, child: Text("Milníky", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          _milestone(state.userLevel >= 10, "Světlonoš", "Odemkne se na Levelu 10"),
          _milestone(state.userLevel >= 5, "Hledač", "Odemkne se na Levelu 5"),
          _milestone(state.userLevel >= 1, "Poutník", "Dokončeno"),
        ],
      ).animate().slideY(begin: 0.1, end: 0),
    );
  }

  Widget _milestone(bool unlocked, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(unlocked ? Icons.check_circle : Icons.lock, color: unlocked ? const Color(0xFF00D2FF) : Colors.white24),
          const SizedBox(width: 15),
          Expanded(
            child: GlassCard(
              opacity: unlocked ? 0.1 : 0.02,
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: unlocked ? Colors.white : Colors.white38, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// C. CREATE SCREEN (ADD POST)
class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});
  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  double _stressVal = 5;
  final TextEditingController _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit_note, size: 50, color: Colors.white54),
            const SizedBox(height: 20),
            Text("Vyslat Signál", style: GoogleFonts.cinzel(fontSize: 32, color: Colors.white)),
            const SizedBox(height: 40),
            
            GlassCard(
              opacity: 0.1,
              child: TextField(
                controller: _ctrl,
                maxLines: 5,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: const InputDecoration(
                  hintText: "Co tě trápí? Nebo za co jsi vděčný? ...",
                  hintStyle: TextStyle(color: Colors.white30),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Research Input
            const Text("Jakou tíhu cítíš? (Research)", style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.sentiment_satisfied, color: Colors.green),
                Expanded(
                  child: Slider(
                    value: _stressVal, min: 0, max: 10, divisions: 10, label: _stressVal.round().toString(),
                    activeColor: const Color(0xFF6C63FF),
                    onChanged: (v) => setState(() => _stressVal = v),
                  ),
                ),
                const Icon(Icons.sentiment_very_dissatisfied, color: Colors.red),
              ],
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (_ctrl.text.isNotEmpty) {
                    context.read<AppState>().addPost(_ctrl.text, _stressVal);
                    context.read<AppState>().setIndex(0); // Jdi zpět na feed
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signál odeslán. +50 Bodů."), backgroundColor: Color(0xFF6C63FF)));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 10
                ),
                child: const Text("ODESLAT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            )
          ],
        ),
      ).animate().scale(),
    );
  }
}

// D. INSIGHTS SCREEN (MOCK CHARTS)
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text("Vhledy & Data", style: GoogleFonts.cinzel(fontSize: 28, fontWeight: FontWeight.bold)),
          const Text("Tvá spirituální analytika.", style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 30),
          
          // Chart 1
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Hladina Stresu vs. Modlitba", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [8, 7, 6, 5, 4, 3, 4].map((e) {
                      return Container(
                        width: 20, height: e * 15.0,
                        decoration: BoxDecoration(color: Color.lerp(Colors.green, Colors.red, e/10), borderRadius: BorderRadius.circular(5)),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Data naznačují pokles stresu o 40% v dnech s aktivitou.", style: TextStyle(fontSize: 10, color: Colors.white54)),
              ],
            ),
          ),
          const SizedBox(height: 20),
           GlassCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Celková komunita", style: TextStyle(color: Colors.white54)),
                  Text("12,450", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber)),
                ]),
                Icon(Icons.public, size: 40, color: Colors.white10),
              ],
            ),
          )
        ],
      ).animate().fadeIn(),
    );
  }
}

// E. CHARITY SCREEN
class CharityScreen extends StatelessWidget {
  const CharityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text("Dopad", style: GoogleFonts.cinzel(fontSize: 28, fontWeight: FontWeight.bold)),
          const Text("Kde modlitba pomáhá hmotně.", style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 30),
          
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)]),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: const Color(0xFF00D2FF).withValues(alpha: 0.4), blurRadius: 20)]
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Vybráno tento měsíc", style: TextStyle(color: Colors.white70)),
                  Text("45,200 Kč", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ]),
                Icon(Icons.volunteer_activism, size: 40, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text("Projekty", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _projectCard("Voda pro Afriku", 0.7, Colors.cyan),
          _projectCard("Škola v Nepálu", 0.4, Colors.orange),
          _projectCard("Oprava kapličky", 0.9, Colors.green),
        ],
      ).animate().slideX(),
    );
  }

  Widget _projectCard(String title, double progress, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress, backgroundColor: Colors.white10, color: color, minHeight: 6, borderRadius: BorderRadius.circular(5)),
            const SizedBox(height: 5),
            Text("${(progress*100).toInt()}% financováno", style: const TextStyle(fontSize: 10, color: Colors.white38)),
          ],
        ),
      ),
    );
  }
}

// F. AURA CHAT MODAL
void _showAuraChat(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const AuraChatSheet(),
  );
}

class AuraChatSheet extends StatefulWidget {
  const AuraChatSheet({super.key});
  @override
  State<AuraChatSheet> createState() => _AuraChatSheetState();
}

class _AuraChatSheetState extends State<AuraChatSheet> {
  final _ctrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF101015),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF6C63FF)),
              const SizedBox(width: 10),
              Text("Aura AI", style: GoogleFonts.cinzel(fontSize: 20, color: Colors.white)),
              const Spacer(),
              IconButton(onPressed: ()=>Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white54))
            ]),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: state.auraMessages.length,
              itemBuilder: (ctx, i) {
                final msg = state.auraMessages[i];
                return Align(
                  alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: msg.isMe ? const Color(0xFF6C63FF) : Colors.white10,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20), topRight: const Radius.circular(20),
                        bottomLeft: msg.isMe ? const Radius.circular(20) : Radius.zero,
                        bottomRight: msg.isMe ? Radius.zero : const Radius.circular(20)
                      )
                    ),
                    child: Text(msg.text, style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
            color: Colors.black26,
            child: Row(children: [
              Expanded(child: TextField(
                controller: _ctrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: "Napiš zprávu...", hintStyle: const TextStyle(color: Colors.white38), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none), filled: true, fillColor: Colors.white10, contentPadding: const EdgeInsets.symmetric(horizontal: 20)),
              )),
              const SizedBox(width: 10),
              CircleAvatar(backgroundColor: const Color(0xFF6C63FF), child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 18), onPressed: (){
                if(_ctrl.text.isNotEmpty) {
                  context.read<AppState>().sendMessageToAura(_ctrl.text);
                  _ctrl.clear();
                }
              }))
            ]),
          )
        ],
      ),
    );
  }
}