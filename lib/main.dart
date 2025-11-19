import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

// --- 1. GAMIFICATION ENGINE & MODELS ---

enum FaithType { christian, muslim, atheist, spiritual, universal }
enum ActionType { lightCandle, deepPrayer, dailyLogin, share }

class UserProfile {
  String nickname;
  FaithType faith;
  bool isIncognito;
  int auraPoints;
  int treeLevel;
  int dayStreak; // Sádhaná - konzistence
  double currentStressLevel;

  UserProfile({
    this.nickname = "Poutník",
    this.faith = FaithType.spiritual,
    this.isIncognito = false,
    this.auraPoints = 0,
    this.treeLevel = 1,
    this.dayStreak = 1,
    this.currentStressLevel = 5.0,
  });

  // Výpočet titulu podle levelu (Gamifikace dokument str. 1)
  String get Title {
    if (treeLevel < 3) return "Poutník";
    if (treeLevel < 7) return "Hledač";
    if (treeLevel < 15) return "Strážce";
    if (treeLevel < 30) return "Světlonoš";
    return "Avatar";
  }
}

class AppState extends ChangeNotifier {
  UserProfile user = UserProfile();
  List<PrayerCardModel> prayers = [];
  
  // Gamifikační tabulka odměn (podle dokumentu)
  final Map<ActionType, int> _pointsTable = {
    ActionType.lightCandle: 5,  // Zapálení Díji
    ActionType.deepPrayer: 20,  // Bhakti / Hluboká podpora
    ActionType.dailyLogin: 10,  // Denní Prárthaná
    ActionType.share: 50,       // Evangelizace / Sdílení
  };

  // --- THEME & SKINNING ---
  ThemeData get currentTheme {
    Color primaryColor;
    switch (user.faith) {
      case FaithType.christian: primaryColor = Colors.amber; break; 
      case FaithType.muslim: primaryColor = Colors.green; break;
      case FaithType.atheist: primaryColor = Colors.teal; break;
      default: primaryColor = Colors.purpleAccent;
    }

    return ThemeData.dark().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF0A0A12),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: Colors.white70,
        surface: const Color(0xFF151520),
      ),
      textTheme: GoogleFonts.ralewayTextTheme(ThemeData.dark().textTheme),
    );
  }

  String get termCurrency {
    switch (user.faith) {
      case FaithType.christian: return "Milost";
      case FaithType.muslim: return "Hasanat";
      case FaithType.atheist: return "Kredity";
      default: return "Aura";
    }
  }

  // --- LOGIC ---

  void generateMockData() {
    prayers = [
      PrayerCardModel(author: "Maria, BR", content: "Prosím za uzdravení. Čekají nás testy.", supporters: 124, countryCode: "BR"),
      PrayerCardModel(author: "Unknown", content: "Mám strach z budoucnosti.", supporters: 89, countryCode: "US", isAnonymous: true),
      PrayerCardModel(author: "David, CZ", content: "Díky za sílu zvládnout dnešní den.", supporters: 256, countryCode: "CZ", type: PrayerType.gratitude),
    ];
    notifyListeners();
  }

  // CORE GAMIFICATION FUNCTION
  void performAction(ActionType action, {int? cardIndex}) {
    int points = _pointsTable[action] ?? 0;
    
    // 1. Přičíst body
    user.auraPoints += points;
    
    // 2. Aktualizovat modlitbu (pokud se vztahuje ke kartě)
    if (cardIndex != null) {
      prayers[cardIndex].supporters++;
      prayers[cardIndex].isSupportedByMe = true;
    }

    // 3. Kontrola Level Up (Exponenciální křivka)
    // Level = sqrt(Points / 50) ... zjednodušená logika
    int newLevel = (sqrt(user.auraPoints) / 2).floor();
    if (newLevel < 1) newLevel = 1;
    
    if (newLevel > user.treeLevel) {
      user.treeLevel = newLevel;
      // Tady by se spustila "Level Up" animace
    }

    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void updateProfile(FaithType faith, bool incognito) {
    user.faith = faith;
    user.isIncognito = incognito;
    notifyListeners();
  }

  void submitStressLevel(double value) {
    user.currentStressLevel = value;
    notifyListeners();
  }
}

enum PrayerType { request, gratitude }

class PrayerCardModel {
  final String author;
  final String content;
  int supporters;
  final String countryCode;
  final bool isAnonymous;
  final PrayerType type;
  bool isSupportedByMe;

  PrayerCardModel({
    required this.author,
    required this.content,
    required this.supporters,
    required this.countryCode,
    this.isAnonymous = false,
    this.type = PrayerType.request,
    this.isSupportedByMe = false,
  });
}

// --- 2. HLAVNÍ APLIKACE ---

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState()..generateMockData(),
      child: const PrayaApp(),
    ),
  );
}

class PrayaApp extends StatelessWidget {
  const PrayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    return MaterialApp(
      title: 'Praya.app',
      debugShowCheckedModeBanner: false,
      theme: appState.currentTheme,
      home: const OnboardingScreen(),
    );
  }
}

// --- 3. OBRAZOVKY ---

// A. ONBOARDING
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  FaithType selectedFaith = FaithType.spiritual;
  bool incognito = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.public, size: 80, color: Colors.white70).animate().fadeIn(duration: 1000.ms),
              const SizedBox(height: 20),
              Text("PRAYA", style: GoogleFonts.cinzel(fontSize: 40, color: Colors.white, letterSpacing: 5)),
              Text("Gamified Spirituality.", style: GoogleFonts.raleway(color: Colors.white54)),
              const SizedBox(height: 60),
              Text("Vyberte svou cestu:", style: GoogleFonts.raleway(fontSize: 18, color: Colors.white)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
                children: FaithType.values.map((faith) {
                  return ChoiceChip(
                    label: Text(faith.toString().split('.').last.toUpperCase()),
                    selected: selectedFaith == faith,
                    onSelected: (selected) => setState(() => selectedFaith = faith),
                    selectedColor: Colors.purpleAccent.withValues(alpha: 0.5),
                    backgroundColor: Colors.black26,
                    labelStyle: const TextStyle(color: Colors.white),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              SwitchListTile(
                title: const Text("Incognito Monk Mode", style: TextStyle(color: Colors.white)),
                value: incognito,
                activeTrackColor: Colors.purpleAccent,
                onChanged: (val) => setState(() => incognito = val),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {
                  context.read<AppState>().updateProfile(selectedFaith, incognito);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigation()));
                },
                child: const Text("START JOURNEY"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// B. MAIN NAVIGATION
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  final pages = [const FeedScreen(), const TreeProfileScreen()];

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var user = context.watch<AppState>().user;
    
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0A0A12),
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.white24,
        currentIndex: _index,
        onTap: (idx) => setState(() => _index = idx),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.waves), label: "Řeka"),
          BottomNavigationBarItem(icon: const Icon(Icons.park), label: user.Title), // Dynamický label
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.auto_awesome),
        onPressed: () => _showAuraAIChat(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// C. FEED SCREEN
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A12),
        title: Row(
          children: [
            Text("Řeka", style: GoogleFonts.cinzel(color: Colors.white)),
            const Spacer(),
            const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
            Text(" ${state.user.dayStreak} dnů", style: const TextStyle(color: Colors.orange, fontSize: 12)),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.prayers.length,
        itemBuilder: (ctx, i) => _buildPrayerCard(context, state.prayers[i], i, state),
      ),
    );
  }

  Widget _buildPrayerCard(BuildContext context, PrayerCardModel prayer, int index, AppState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151520),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: prayer.isSupportedByMe ? state.currentTheme.primaryColor.withValues(alpha: 0.5) : Colors.transparent,
        ),
        boxShadow: [
          if (prayer.isSupportedByMe)
            BoxShadow(color: state.currentTheme.primaryColor.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 1)
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 12, backgroundColor: Colors.white10, child: Text(prayer.countryCode, style: const TextStyle(fontSize: 10))),
              const SizedBox(width: 10),
              Text(prayer.isAnonymous ? "Tichý Poutník" : prayer.author, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 15),
          Text(prayer.content, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white)),
          const SizedBox(height: 20),
          
          // GAMIFICATION ACTIONS ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. LIGHT CANDLE (Tap)
              InkWell(
                onTap: () {
                  state.performAction(ActionType.lightCandle, cardIndex: index);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("+5 ${state.termCurrency} (Zapáleno)"),
                    backgroundColor: state.currentTheme.primaryColor,
                    duration: const Duration(milliseconds: 500),
                  ));
                },
                child: Chip(
                  avatar: const Icon(Icons.light_mode, size: 14),
                  label: Text("Svíčka (${prayer.supporters})"),
                  backgroundColor: Colors.white10,
                ),
              ),
              
              // 2. DEEP PRAYER (Long Press)
              InkWell(
                onLongPress: () {
                   state.performAction(ActionType.deepPrayer, cardIndex: index);
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("+20 (Hluboká podpora!)"),
                    backgroundColor: Colors.amber,
                  ));
                },
                child: const Chip(
                  avatar: Icon(Icons.self_improvement, size: 14),
                  label: Text("Meditovat"),
                  backgroundColor: Colors.white10,
                ),
              ),
            ],
          )
        ],
      ),
    ).animate().slideY(begin: 0.2, end: 0, duration: 500.ms);
  }
}

// D. PROFILE SCREEN (Gamified)
class TreeProfileScreen extends StatelessWidget {
  const TreeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatBadge("Level", state.user.treeLevel.toString(), Colors.blue),
                _buildStatBadge(state.termCurrency, state.user.auraPoints.toString(), state.currentTheme.primaryColor),
                _buildStatBadge("Streak", "${state.user.dayStreak} dnů", Colors.orange),
              ],
            ),
            const SizedBox(height: 40),
            
            // THE TREE
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.park, size: 150 + (state.user.treeLevel * 5), color: state.currentTheme.primaryColor.withValues(alpha: 0.8))
                .animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2000.ms),
                
                if (state.user.treeLevel > 5) // Glow effect for higher levels
                  Positioned.fill(child: Icon(Icons.park, size: 160, color: state.currentTheme.primaryColor.withValues(alpha: 0.3)).animate().scale(begin: const Offset(1,1), end: const Offset(1.2, 1.2))),
              ],
            ),
            
            const SizedBox(height: 20),
            Text(state.user.Title.toUpperCase(), style: GoogleFonts.cinzel(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
            Text("Další level za ${(state.user.treeLevel + 1) * 50 - state.user.auraPoints} bodů", style: const TextStyle(color: Colors.white30)),
            
            const Spacer(),
            // Research Slider
             Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  const Text("Research: Stress Level", style: TextStyle(color: Colors.white54)),
                  Slider(
                    value: state.user.currentStressLevel,
                    min: 0, max: 10, divisions: 10,
                    activeColor: state.currentTheme.primaryColor,
                    onChanged: (val) => state.submitStressLevel(val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.cinzel(fontSize: 24, color: color, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}

// E. AI CHAT
void _showAuraAIChat(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.black.withValues(alpha: 0.9),
    builder: (ctx) => Container(
      padding: const EdgeInsets.all(20),
      child: const Center(child: Text("Aura AI se probouzí...", style: TextStyle(color: Colors.white))),
    ),
  );
}